import AozoraAPI
import AozoraAPIResponse
import Testing

@Suite("GET /books/{bookId}")
struct GetBookRequestTests {
    private func book(_ json: String) async throws -> BookResponse {
        try await GetBookRequest(bookId: 1567).response(api: .stub(returning: json))
    }

    /// 列の取り違えを見るため、すべての項目に違う値を入れる。
    @Test("すべての項目が対応する場所に入る")
    func mapsEveryField() async throws {
        let book = try await book("""
        {
          "id": 1567,
          "title": "走れメロス",
          "titleKana": "はしれメロス",
          "subtitle": "副題",
          "firstAppearance": "「新潮」1940（昭和15）年5月号",
          "ndc": "NDC 913",
          "kanaType": "新字新仮名",
          "copyright": false,
          "releaseDate": "2000-12-04",
          "cardUrl": "https://www.aozora.gr.jp/cards/000035/card1567.html",
          "textUrl": "https://www.aozora.gr.jp/cards/000035/files/1567_ruby_4948.zip",
          "htmlUrl": "https://www.aozora.gr.jp/cards/000035/files/1567_14913.html",
          "contributors": [
            {
              "personId": 35, "name": "太宰 治", "role": "著者",
              "birthDate": "1909-06-19", "deathDate": "1948-06-13"
            }
          ]
        }
        """)

        #expect(book.id == 1567)
        #expect(book.title == "走れメロス")
        #expect(book.titleKana == "はしれメロス")
        #expect(book.subtitle == "副題")
        #expect(book.firstAppearance == "「新潮」1940（昭和15）年5月号")
        #expect(book.ndc == "NDC 913")
        #expect(book.kanaType == "新字新仮名")
        #expect(book.copyright == false)
        #expect(book.releaseDate == "2000-12-04")
        #expect(book.cardUrl == "https://www.aozora.gr.jp/cards/000035/card1567.html")
        #expect(book.textUrl == "https://www.aozora.gr.jp/cards/000035/files/1567_ruby_4948.zip")
        #expect(book.htmlUrl == "https://www.aozora.gr.jp/cards/000035/files/1567_14913.html")
        #expect(book.contributors == [
            ContributorResponse(
                personId: 35,
                name: "太宰 治",
                role: "著者",
                birthDate: "1909-06-19",
                deathDate: "1948-06-13"
            ),
        ])
    }

    /// 生没年は片方だけ欠けることがある。
    @Test("生没年が無くても通る")
    func acceptsMissingDates() async throws {
        let book = try await book("""
        {
          "id": 798, "title": "手紙", "copyright": false,
          "contributors": [
            { "personId": 148, "name": "夏目 漱石", "role": "著者", "birthDate": "1867-02-09" }
          ]
        }
        """)

        let contributor = try #require(book.contributors.first)
        #expect(contributor.birthDate == "1867-02-09")
        #expect(contributor.deathDate == nil)
    }
}
