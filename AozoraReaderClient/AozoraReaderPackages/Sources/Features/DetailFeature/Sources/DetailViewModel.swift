import AozoraAPIResponse
import Foundation
import Observation
import Repository

@MainActor
@Observable
public final class DetailViewModel {
    private(set) var book: BookResponse?

    private let bookId: Int
    private let repository: any BookRepositoryProtocol

    public init(bookId: Int, repository: any BookRepositoryProtocol = BookRepository()) {
        self.bookId = bookId
        self.repository = repository
    }

    public func task() async {
        book = try? await repository.book(id: bookId)
    }
}
