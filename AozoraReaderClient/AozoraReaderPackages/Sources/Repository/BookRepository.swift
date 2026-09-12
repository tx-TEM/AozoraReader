import AozoraAPI
import AozoraAPIResponse

public struct BookRepository: BookRepositoryProtocol {
    private let api: AozoraAPIClient

    public init(api: AozoraAPIClient = AozoraAPIClient()) {
        self.api = api
    }

    public func books(q: String?, personId: Int?, limit: Int, offset: Int) async throws -> BookPageResponse {
        try await GetBooksRequest(q: q, personId: personId, limit: limit, offset: offset)
            .response(api: api)
    }
}
