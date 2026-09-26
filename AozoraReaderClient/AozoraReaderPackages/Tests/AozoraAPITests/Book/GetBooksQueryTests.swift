import AozoraAPI
import Testing

@Suite("GET /books のクエリ")
struct GetBooksQueryTests {
    private static let emptyPage = #"{ "total": 0, "limit": 50, "offset": 0, "items": [] }"#

    private func path(for request: GetBooksRequest) async throws -> String {
        let recorder = RequestRecorder()
        _ = try await request.response(api: .stub(returning: Self.emptyPage, recorder: recorder))
        return try #require(await recorder.lastPath)
    }

    /// title と author の取り違えを見るため、別々の値を入れる。
    @Test("title と author が別々のパラメータで送られる")
    func sendsTitleAndAuthorSeparately() async throws {
        let path = try await path(for: GetBooksRequest(
            title: "melos", author: "dazai", limit: 50, offset: 0
        ))

        #expect(path.contains("title=melos"))
        #expect(path.contains("author=dazai"))
    }

    @Test("渡さなかった絞り込みは送らない")
    func omitsUnsetFilters() async throws {
        let path = try await path(for: GetBooksRequest(title: "melos", limit: 50, offset: 0))

        #expect(path.contains("title=melos"))
        #expect(!path.contains("author="))
        #expect(!path.contains("personId="))
    }

    @Test("limit と offset は必ず送る")
    func alwaysSendsPaging() async throws {
        let path = try await path(for: GetBooksRequest(limit: 50, offset: 100))

        #expect(path.contains("limit=50"))
        #expect(path.contains("offset=100"))
    }

    @Test("personId が送られる")
    func sendsPersonId() async throws {
        let path = try await path(for: GetBooksRequest(personId: 35, limit: 50, offset: 0))

        #expect(path.contains("personId=35"))
    }
}
