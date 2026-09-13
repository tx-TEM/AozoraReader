import AozoraAPIResponse
import Foundation
import Observation
import Repository
import Utils

@MainActor
@Observable
public final class BrowseViewModel {
    static let pageSize = 50
    /// 未表示がこれだけになったら次の 50 件を取りに行く。
    static let prefetchDistance = 20
    static let debounce = Duration.milliseconds(300)

    /// これを超えて結果が来ないときだけスピナーを出す。
    static let spinnerDelay = Duration.milliseconds(250)

    private(set) var books: [BookSummaryResponse] = []
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
    /// 絞り込みに一致する総件数。ここに達したら取りに行かない。
    private var total = 0
    private var isLoadingNextPage = false

    private var title: String? {
        keyword.isEmpty ? nil : keyword
    }

    public init(repository: any BookRepositoryProtocol = BookRepository()) {
        self.repository = repository
    }

    func task() async {
        await search()
    }

    /// 一覧の行が出たときに呼ぶ。末尾に近ければ次の 50 件を取りに行く。
    func rowAppeared(_ book: BookSummaryResponse) async {
        guard books.suffix(Self.prefetchDistance).contains(where: { $0.id == book.id }) else { return }
        await loadNextPage()
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
                title: title,
                author: nil,
                personId: nil,
                limit: Self.pageSize,
                offset: 0
            )
        }

        // 捨てられたリクエストの結果は使わない。古い一覧を残す。
        guard Task.isNotCancelled, let page else { return }
        books = page.items
        total = page.total
    }

    /// 次の 50 件を足す。取得中は始めず、総件数に達したら打ち切る。
    private func loadNextPage() async {
        guard !isLoadingNextPage, books.count < total else { return }
        isLoadingNextPage = true
        defer { isLoadingNextPage = false }

        let keyword = keyword
        let page = try? await repository.books(
            title: title,
            author: nil,
            personId: nil,
            limit: Self.pageSize,
            offset: books.count
        )

        // 待っているあいだに絞り込みが変わっていたら、その結果は繋がらない。
        guard let page, keyword == self.keyword, page.offset == books.count else { return }
        books += page.items
        total = page.total
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
