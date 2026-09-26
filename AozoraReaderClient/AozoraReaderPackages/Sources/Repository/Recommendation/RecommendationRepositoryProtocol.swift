import AozoraAPIResponse

/// おすすめを取ってくる窓口。
public protocol RecommendationRepositoryProtocol: Sendable {
    /// おすすめをカテゴリーごとに取得する。
    @concurrent
    func recommendations() async throws -> RecommendationsResponse
}
