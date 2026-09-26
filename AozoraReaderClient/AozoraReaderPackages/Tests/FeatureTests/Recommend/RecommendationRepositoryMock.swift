import AozoraAPIResponse
import Repository
import Testing

/// 振る舞いを init で受け取る。渡さなかったメソッドが呼ばれたら、テストを失敗させる。
struct RecommendationRepositoryMock: RecommendationRepositoryProtocol {
    struct Unimplemented: Error {}

    private let recommendationsHandler: @Sendable () async throws -> RecommendationsResponse

    init(
        recommendations: @escaping @Sendable () async throws -> RecommendationsResponse = {
            Issue.record("recommendations() の振る舞いを渡していないのに呼ばれた")
            throw Unimplemented()
        }
    ) {
        recommendationsHandler = recommendations
    }

    func recommendations() async throws -> RecommendationsResponse {
        try await recommendationsHandler()
    }
}
