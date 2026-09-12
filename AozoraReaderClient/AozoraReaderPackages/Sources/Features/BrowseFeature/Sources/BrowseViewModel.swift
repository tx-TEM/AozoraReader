import AozoraAPIResponse
import Foundation
import Observation
import Repository
import Utils

@MainActor
@Observable
public final class BrowseViewModel {
    static let pageSize = 50
    static let debounce = Duration.milliseconds(300)

    /// これを超えて結果が来ないときだけスピナーを出す。
    static let spinnerDelay = Duration.milliseconds(250)

    private(set) var books: [BookResponse] = []
    private(set) var isLoading = false

    var keyword: String = "" {
        didSet {
            guard oldValue != keyword else { return }
            scheduleSearch(after: Self.debounce)
        }
    }

    /// 変換が確定していない文字列を編集中かどうか。
    var isComposing: Bool = false {
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

    func task() async {
        await search()
    }
}

// MARK: - 検索処理

extension BrowseViewModel {
    /// 取得中のものがあれば捨てて、取り直す。
    private func scheduleSearch(after delay: Duration) {
        searchTask?.cancel()
        searchTask = Task { [weak self] in
            if delay > .zero {
                try? await Task.sleep(for: delay)
            }
            guard Task.isNotCancelled else { return }
            await self?.search()
        }
    }

    private func search() async {
        let page = await showingSpinner {
            try? await repository.books(
                title: keyword.isEmpty ? nil : keyword,
                author: nil,
                personId: nil,
                limit: Self.pageSize,
                offset: 0
            )
        }

        // 捨てられたリクエストの結果は使わない。古い一覧を残す。
        guard Task.isNotCancelled, let page else { return }
        books = page.items
    }

    /// `work` が ``spinnerDelay`` を超えたときだけスピナーを出す。
    private func showingSpinner<T>(_ work: () async -> T) async -> T {
        let spinner = Task { [weak self] in
            try? await Task.sleep(for: Self.spinnerDelay)
            guard Task.isNotCancelled else { return }
            self?.isLoading = true
        }
        defer {
            spinner.cancel()
            isLoading = false
        }
        return await work()
    }
}
