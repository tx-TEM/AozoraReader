import AozoraAPIResponse
import Observation
import Repository

@MainActor
@Observable
public final class BrowseViewModel {
    public private(set) var books: [BookResponse] = []

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
