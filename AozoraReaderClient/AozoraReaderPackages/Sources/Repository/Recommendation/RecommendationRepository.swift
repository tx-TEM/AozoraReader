import AozoraAPI
import AozoraAPIResponse

public struct RecommendationRepository: RecommendationRepositoryProtocol {
    private let api: AozoraAPIClient

    public init(api: AozoraAPIClient = AozoraAPIClient()) {
        self.api = api
    }

    @concurrent
    public func recommendations() async throws -> RecommendationsResponse {
        try await GetRecommendationsRequest().response(api: api)
    }
}
