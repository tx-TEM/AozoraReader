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
