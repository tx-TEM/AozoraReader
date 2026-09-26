import AozoraAPI
import AozoraAPIResponse

public struct BookRepository: BookRepositoryProtocol {
    private let api: AozoraAPIClient

    public init(api: AozoraAPIClient = AozoraAPIClient()) {
        self.api = api
    }

    public func books(
        title: String?,
        author: String?,
        personId: Int?,
        limit: Int,
        offset: Int
    ) async throws -> BookPageResponse {
        try await GetBooksRequest(
            title: title,
            author: author,
            personId: personId,
            limit: limit,
            offset: offset
        ).response(api: api)
    }

    public func book(id: Int) async throws -> BookResponse {
        try await GetBookRequest(bookId: id).response(api: api)
    }
}
