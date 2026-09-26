import AozoraAPI
import AozoraAPIResponse
import Testing

@Suite("GET /books")
struct GetBooksRequestTests {
    private func books(_ json: String) async throws -> BookPageResponse {
        try await GetBooksRequest(limit: 50, offset: 0).response(api: .stub(returning: json))
    }

    /// 列の取り違えを見るため、すべての項目に違う値を入れる。
    @Test("すべての項目が対応する場所に入る")
    func mapsEveryField() async throws {
        let page = try await books("""
        {
          "total": 17717,
          "limit": 50,
          "offset": 100,
          "items": [
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
        """)

        #expect(page.total == 17717)
        #expect(page.limit == 50)
        #expect(page.offset == 100)

        let book = try #require(page.items.first)
        #expect(book.id == 1567)
        #expect(book.title == "走れメロス")
        #expect(book.subtitle == "副題")
        #expect(book.contributors == [ContributorSummaryResponse(personId: 35, name: "太宰 治", role: "著者")])
    }

    /// 副題を持たない作品はキーごと省かれる。
    @Test("required 以外のキーが無くても通る")
    func acceptsOmittedKeys() async throws {
        let page = try await books("""
        {
          "total": 1, "limit": 50, "offset": 0,
          "items": [
            {
              "id": 798,
              "title": "手紙",
              "contributors": [
                { "personId": 148, "name": "夏目 漱石", "role": "著者" }
              ]
            }
          ]
        }
        """)

        #expect(try #require(page.items.first).subtitle == nil)
    }

    /// 仕様上は空文字も許される。キーが無い場合とは区別される。
    @Test("空文字は空文字のまま届く")
    func keepsEmptyStringsAsIs() async throws {
        let page = try await books("""
        {
          "total": 1, "limit": 50, "offset": 0,
          "items": [
            { "id": 798, "title": "手紙", "subtitle": "", "contributors": [] }
          ]
        }
        """)

        #expect(try #require(page.items.first).subtitle == "")
    }

    @Test("contributors が空でも通る")
    func acceptsEmptyContributors() async throws {
        let page = try await books("""
        {
          "total": 1, "limit": 50, "offset": 0,
          "items": [
            { "id": 798, "title": "手紙", "contributors": [] }
          ]
        }
        """)

        #expect(try #require(page.items.first).contributors.isEmpty)
    }

    /// role の文字列順・人物IDの昇順で並ぶ。並べ替えずに渡す。
    @Test("contributors の並びを変えない")
    func keepsContributorOrder() async throws {
        let page = try await books("""
        {
          "total": 1, "limit": 50, "offset": 0,
          "items": [
            {
              "id": 193, "title": "尼",
              "contributors": [
                { "personId": 129, "name": "森 鴎外", "role": "翻訳者" },
                { "personId": 315, "name": "森 林太郎", "role": "翻訳者" },
                { "personId": 17, "name": "ウィード グスターフ", "role": "著者" }
              ]
            }
          ]
        }
        """)

        let book = try #require(page.items.first)
        #expect(book.contributors.map(\.personId) == [129, 315, 17])
        #expect(book.contributors.map(\.role) == ["翻訳者", "翻訳者", "著者"])
    }

    @Test("items が空でも通る")
    func acceptsEmptyItems() async throws {
        let page = try await books("""
        { "total": 0, "limit": 50, "offset": 0, "items": [] }
        """)

        #expect(page.total == 0)
        #expect(page.items.isEmpty)
    }
}
