import AozoraAPIResponse

/// 作品を一覧・検索する。
///
/// - Remark: GET /books
public struct GetBooksRequest: AozoraAPIRequest {
    public typealias Response = BookPageResponse

    internal let query: Operations.GetBooks.Input.Query

    /// - Parameters:
    ///   - title: 作品名・作品名読みの部分一致で絞り込む。
    ///   - author: 人物名の部分一致で絞り込む。
    ///   - personId: 指定した人物が関わる作品だけに絞り込む。
    ///   - limit: 取得件数。サーバー側で 1〜200 に丸められる。
    ///   - offset: 取得開始位置。負数はサーバー側で 0 に丸められる。
    public init(
        title: String? = nil,
        author: String? = nil,
        personId: Int? = nil,
        limit: Int,
        offset: Int
    ) {
        query = .init(title: title, author: author, personId: personId, limit: limit, offset: offset)
    }

    @concurrent
    public func response(api: AozoraAPIClient) async throws -> BookPageResponse {
        let output = try await api.client.getBooks(query: query)
        return BookPageResponse(response: try output.ok.body.json)
    }
}

/// 作品を 1 件取得する。
///
/// - Remark: GET /books/{bookId}
public struct GetBookRequest: AozoraAPIRequest {
    public typealias Response = BookResponse

    private let bookId: Int

    public init(bookId: Int) {
        self.bookId = bookId
    }

    @concurrent
    public func response(api: AozoraAPIClient) async throws -> BookResponse {
        let output = try await api.client.getBook(path: .init(bookId: bookId))
        return BookResponse(response: try output.ok.body.json)
    }
}
