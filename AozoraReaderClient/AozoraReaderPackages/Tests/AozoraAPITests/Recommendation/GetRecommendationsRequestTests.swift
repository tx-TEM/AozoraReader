import AozoraAPI
import AozoraAPIResponse
import Testing

@Suite("GET /recommendations")
struct GetRecommendationsRequestTests {
    private func recommendations(_ json: String) async throws -> RecommendationsResponse {
        try await GetRecommendationsRequest().response(api: .stub(returning: json))
    }

    /// 列の取り違えを見るため、すべての項目に違う値を入れる。
    @Test("すべての項目が対応する場所に入る")
    func mapsEveryField() async throws {
        let recommendations = try await recommendations("""
        {
          "sections": [
            {
              "category": { "id": "9", "name": "文学" },
              "books": [
                {
                  "id": 1567,
                  "title": "走れメロス",
                  "subtitle": "副題",
                  "contributors": [
                    { "personId": 35, "name": "太宰 治", "role": "著者" }
                  ]
                }
              ]
            }
          ]
        }
        """)

        let section = try #require(recommendations.sections.first)
        #expect(section.category == CategoryResponse(id: "9", name: "文学"))
        #expect(section.books == [
            BookSummaryResponse(
                id: 1567,
                title: "走れメロス",
                subtitle: "副題",
                contributors: [ContributorSummaryResponse(personId: 35, name: "太宰 治", role: "著者")]
            ),
        ])
    }

    @Test("セクションはサーバーが返した順に並ぶ")
    func keepsSectionOrder() async throws {
        let recommendations = try await recommendations("""
        {
          "sections": [
            { "category": { "id": "0", "name": "総記" }, "books": [] },
            { "category": { "id": "9", "name": "文学" }, "books": [] },
            { "category": { "id": "other", "name": "その他" }, "books": [] }
          ]
        }
        """)

        #expect(recommendations.sections.map(\.category.id) == ["0", "9", "other"])
    }
}
