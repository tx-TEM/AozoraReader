import AozoraAPIResponse
import Observation
import Repository

@MainActor
@Observable
public final class BrowseViewModel {
    public private(set) var books: [BookResponse] = []

    /// 絞り込みのキーワード。
    public var keyword: String = ""
    /// 変換が確定していない文字列を編集中かどうか。
    public var isComposing: Bool = false

    private let repository: any BookRepositoryProtocol

    public init(repository: any BookRepositoryProtocol = BookRepository()) {
        self.repository = repository
    }

    public func load() async {
        let page = try? await repository.books(
            title: nil,
            author: nil,
            personId: nil,
            limit: 50,
            offset: 0
        )
        books = page?.items ?? []
    }
}
