import AozoraAPIResponse

/// 作品を一覧・検索する。
///
/// - Remark: GET /books
public struct GetBooksRequest: AozoraAPIRequest {
    public typealias Response = BookPageResponse

    internal let query: Operations.GetBooks.Input.Query

    /// - Parameters:
    ///   - q: 作品名・作品名読み・人物名の部分一致で絞り込む。空のときは絞り込まない。
    ///   - personId: 指定した人物が関わる作品だけに絞り込む。`q` と併用すると AND になる。
    ///   - limit: 取得件数。サーバー側で 1〜200 に丸められる。
    ///   - offset: 取得開始位置。負数はサーバー側で 0 に丸められる。
    public init(q: String? = nil, personId: Int? = nil, limit: Int, offset: Int) {
        query = .init(q: q, personId: personId, limit: limit, offset: offset)
    }

    public func response(api: AozoraAPIClient) async throws -> BookPageResponse {
        let output = try await api.client.getBooks(query: query)
        return BookPageResponse(response: try output.ok.body.json)
    }
}
