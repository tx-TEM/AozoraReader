import AozoraAPI
import AozoraAPIResponse
import Foundation

public struct BookRepository: BookRepositoryProtocol {
    private let api: AozoraAPIClient

    public init(api: AozoraAPIClient) {
        self.api = api
    }

    public init(serverURL: URL) {
        self.init(api: AozoraAPIClient(serverURL: serverURL))
    }

    public func books(q: String?, personId: Int?, limit: Int, offset: Int) async throws -> BookPageResponse {
        try await GetBooksRequest(q: q, personId: personId, limit: limit, offset: offset)
            .response(api: api)
    }
}
