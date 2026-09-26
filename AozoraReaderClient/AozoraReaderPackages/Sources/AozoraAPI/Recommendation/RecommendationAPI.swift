import AozoraAPIResponse

/// おすすめをカテゴリーごとに取得する。
///
/// - Remark: GET /recommendations
public struct GetRecommendationsRequest: AozoraAPIRequest {
    public typealias Response = RecommendationsResponse

    public init() {}

    @concurrent
    public func response(api: AozoraAPIClient) async throws -> RecommendationsResponse {
        let output = try await api.client.getRecommendations()
        return RecommendationsResponse(response: try output.ok.body.json)
    }
}
