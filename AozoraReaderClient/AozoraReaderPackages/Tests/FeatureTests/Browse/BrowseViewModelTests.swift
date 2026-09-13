import AozoraAPIResponse
import Testing

@testable import BrowseFeature

@Suite("さがすタブの絞り込み")
@MainActor
struct BrowseViewModelTests {
    private func waitPastDebounce() async throws {
        try await Task.sleep(for: BrowseViewModel.debounce + .milliseconds(200))
    }

    @Test("起動時は絞り込まずに取りに行く")
    func loadsWithoutFilterOnLaunch() async throws {
        let repository = BookRepositoryMock()
        let model = BrowseViewModel(repository: repository)

        await model.task()

        #expect(repository.calls == [.init(title: nil, author: nil, offset: 0)])
    }

    @Test("キーワードを入れると絞り込んで取り直す")
    func searchesWithKeyword() async throws {
        let repository = BookRepositoryMock()
        let model = BrowseViewModel(repository: repository)

        model.keyword = "走れ"
        try await waitPastDebounce()

        #expect(repository.calls == [.init(title: "走れ", author: nil, offset: 0)])
    }

    /// 300ms のあいだに変わり続けるあいだは送らない。
    @Test("打っているあいだは送らず、止まってから1回だけ送る")
    func debouncesWhileTyping() async throws {
        let repository = BookRepositoryMock()
        let model = BrowseViewModel(repository: repository)

        for keyword in ["走", "走れ", "走れメ", "走れメロ", "走れメロス"] {
            model.keyword = keyword
            try await Task.sleep(for: .milliseconds(50))
        }
        #expect(repository.calls.isEmpty)

        try await waitPastDebounce()
        #expect(repository.calls == [.init(title: "走れメロス", author: nil, offset: 0)])
    }

    /// 変換が確定した瞬間はデバウンスを待たない。
    @Test("変換が確定したらすぐ送る")
    func sendsImmediatelyOnCommit() async throws {
        let repository = BookRepositoryMock()
        let model = BrowseViewModel(repository: repository)

        model.isComposing = true
        model.keyword = "たいざい"
        try await Task.sleep(for: .milliseconds(50))
        #expect(repository.calls.isEmpty)

        model.keyword = "太宰"
        model.isComposing = false
        try await Task.sleep(for: .milliseconds(50))

        #expect(repository.calls == [.init(title: "太宰", author: nil, offset: 0)])
    }

    @Test("キーワードを消すと絞り込まない状態に戻る")
    func clearingKeywordRemovesFilter() async throws {
        let repository = BookRepositoryMock()
        let model = BrowseViewModel(repository: repository)

        model.keyword = "走れ"
        try await waitPastDebounce()
        model.keyword = ""
        try await waitPastDebounce()

        #expect(repository.calls.last == .init(title: nil, author: nil, offset: 0))
    }

    /// 結果が届くまでは古い一覧を出したままにする。
    @Test("取得中は前の一覧が残る")
    func keepsPreviousBooksWhileLoading() async throws {
        let repository = BookRepositoryMock()
        repository.items = [.stub(id: 1, title: "走れメロス")]
        let model = BrowseViewModel(repository: repository)
        await model.task()

        repository.items = [.stub(id: 2, title: "человек")]
        repository.delay = .milliseconds(300)
        model.keyword = "手紙"
        try await Task.sleep(for: .milliseconds(400))

        #expect(model.books.map(\.id) == [1])

        try await Task.sleep(for: .milliseconds(300))
        #expect(model.books.map(\.id) == [2])
    }
}

// MARK: - ページング

@Suite("さがすタブのページング")
@MainActor
struct BrowsePagingTests {
    private func loaded(count: Int) async -> (BrowseViewModel, BookRepositoryMock) {
        let repository = BookRepositoryMock()
        repository.items = (1...count).map { .stub(id: $0, title: "\($0)") }
        let model = BrowseViewModel(repository: repository)
        await model.task()
        return (model, repository)
    }

    @Test("末尾から20件のところが出たら次の50件を足す")
    func loadsNextPage() async {
        let (model, repository) = await loaded(count: 120)
        #expect(model.books.count == BrowseViewModel.pageSize)

        await model.rowAppeared(model.books[30])

        #expect(model.books.count == 100)
        #expect(repository.calls.map(\.offset) == [0, 50])
    }

    @Test("末尾から遠い行では取りに行かない")
    func ignoresEarlyRow() async {
        let (model, repository) = await loaded(count: 120)

        await model.rowAppeared(model.books[29])

        #expect(repository.calls.map(\.offset) == [0])
    }

    @Test("総件数に達したら取りに行かない")
    func stopsAtTotal() async {
        let (model, repository) = await loaded(count: 30)

        await model.rowAppeared(model.books[29])

        #expect(repository.calls.map(\.offset) == [0])
    }

    @Test("取得中は次の取得を始めない")
    func ignoresWhileLoading() async {
        let (model, repository) = await loaded(count: 120)
        repository.delay = .milliseconds(100)

        let first = Task { await model.rowAppeared(model.books[49]) }
        let second = Task { await model.rowAppeared(model.books[49]) }
        await first.value
        await second.value

        #expect(repository.calls.map(\.offset) == [0, 50])
    }

    @Test("絞り込みが変わったら最初の50件から取り直す")
    func restartsOnKeywordChange() async throws {
        let (model, repository) = await loaded(count: 120)
        await model.rowAppeared(model.books[30])

        model.keyword = "走れ"
        try await Task.sleep(for: BrowseViewModel.debounce + .milliseconds(200))

        #expect(model.books.count == BrowseViewModel.pageSize)
        #expect(repository.calls.map(\.offset) == [0, 50, 0])
    }
}

// MARK: - 絞り込み対象

@Suite("さがすタブの絞り込み対象")
@MainActor
struct BrowseFilterTargetTests {
    @Test("作者に変えると作者で絞り込む")
    func filtersByAuthor() async throws {
        let repository = BookRepositoryMock()
        let model = BrowseViewModel(repository: repository)

        model.keyword = "太宰"
        model.target = .author
        try await Task.sleep(for: BrowseViewModel.debounce + .milliseconds(200))

        #expect(repository.calls.last == .init(title: nil, author: "太宰", offset: 0))
    }

    @Test("対象を変えたら最初の50件から取り直す")
    func restartsOnTargetChange() async throws {
        let repository = BookRepositoryMock()
        repository.items = (1...120).map { .stub(id: $0, title: "\($0)") }
        let model = BrowseViewModel(repository: repository)

        await model.task()
        await model.rowAppeared(model.books[30])
        model.target = .author
        try await Task.sleep(for: .milliseconds(200))

        #expect(model.books.count == BrowseViewModel.pageSize)
        #expect(repository.calls.map(\.offset) == [0, 50, 0])
    }
}

// MARK: - 取得の失敗

@Suite("さがすタブの取得失敗")
@MainActor
struct BrowseFailureTests {
    @Test("取得に失敗したらエラーになる")
    func failsOnError() async {
        let repository = BookRepositoryMock()
        repository.failure = BookRepositoryMock.Failure()
        let model = BrowseViewModel(repository: repository)

        await model.task()

        #expect(model.hasFailed)
    }

    @Test("もう一度取りに行けば直る")
    func recoversOnRetry() async {
        let repository = BookRepositoryMock()
        repository.items = (1...10).map { .stub(id: $0, title: "\($0)") }
        repository.failure = BookRepositoryMock.Failure()
        let model = BrowseViewModel(repository: repository)
        await model.task()

        repository.failure = nil
        await model.task()

        #expect(!model.hasFailed)
        #expect(model.books.count == 10)
    }
}
