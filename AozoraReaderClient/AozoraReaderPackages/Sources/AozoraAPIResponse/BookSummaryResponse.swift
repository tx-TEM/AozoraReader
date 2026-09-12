/// 一覧に出す項目だけを持つ作品。詳細は `GET /books/{bookId}`。
public struct BookSummaryResponse: Sendable, Hashable, Identifiable {
    public let id: Int
    public let title: String
    public let subtitle: String?
    /// 著者・翻訳者など、この作品に関わった人物。
    ///
    /// 並びは role の文字列順・人物IDの昇順で、役割の重要度順ではない。
    public let contributors: [ContributorResponse]

    public init(
        id: Int,
        title: String,
        subtitle: String? = nil,
        contributors: [ContributorResponse]
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.contributors = contributors
    }
}
