/// ページングされた作品一覧。
public struct BookPageResponse: Sendable, Hashable {
    /// limit と offset を無視した、条件に一致した総件数。
    public let total: Int
    /// 実際に適用された取得件数。リクエスト値を丸めた後の値。
    public let limit: Int
    /// 実際に適用された取得開始位置。リクエスト値を丸めた後の値。
    public let offset: Int
    public let items: [BookResponse]

    public init(total: Int, limit: Int, offset: Int, items: [BookResponse]) {
        self.total = total
        self.limit = limit
        self.offset = offset
        self.items = items
    }
}
