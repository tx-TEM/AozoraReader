import AozoraAPIResponse
import Foundation
import Observation
import Repository

@MainActor
@Observable
public final class BrowseViewModel {
    /// 一度に取得する件数。
    static let pageSize = 50
    /// 入力が止まったと見なすまでの時間。
    static let debounce = Duration.milliseconds(300)
    /// これを超えて結果が来ないときだけスピナーを出す。
    static let spinnerDelay = Duration.milliseconds(250)

    public private(set) var books: [BookResponse] = []
    public private(set) var isLoading = false

    /// 絞り込みのキーワード。
    public var keyword: String = "" {
        didSet {
            guard oldValue != keyword else { return }
            scheduleSearch(after: Self.debounce)
        }
    }

    /// 変換が確定していない文字列を編集中かどうか。
    public var isComposing: Bool = false {
        didSet {
            // 変換が確定した瞬間は、デバウンスを待たずに送る。
            guard oldValue, !isComposing else { return }
            scheduleSearch(after: .zero)
        }
    }

    private let repository: any BookRepositoryProtocol
    private var searchTask: Task<Void, Never>?

    public init(repository: any BookRepositoryProtocol = BookRepository()) {
        self.repository = repository
    }

    public func load() async {
        await search()
    }

    /// 取得中のものがあれば捨てて、取り直す。
    private func scheduleSearch(after delay: Duration) {
        searchTask?.cancel()
        searchTask = Task { [weak self] in
            if delay > .zero {
                try? await Task.sleep(for: delay)
            }
            guard !Task.isCancelled else { return }
            await self?.search()
        }
    }

    private func search() async {
        let spinner = Task { [weak self] in
            try? await Task.sleep(for: Self.spinnerDelay)
            guard !Task.isCancelled else { return }
            self?.isLoading = true
        }
        defer {
            spinner.cancel()
            isLoading = false
        }

        let page = try? await repository.books(
            title: keyword.isEmpty ? nil : keyword,
            author: nil,
            personId: nil,
            limit: Self.pageSize,
            offset: 0
        )

        // 捨てられたリクエストの結果は使わない。古い一覧を残す。
        guard !Task.isCancelled, let page else { return }
        books = page.items
    }
}
