/// 作品の詳細。
///
/// オプショナルな値は、その値を持たない作品では nil。
public struct BookResponse: Sendable, Hashable, Identifiable {
    public let id: Int
    public let title: String
    public let titleKana: String?
    public let subtitle: String?
    public let firstAppearance: String?
    /// 日本十進分類法による分類番号。`NDC 913` のように接頭辞が付く。
    public let ndc: String?
    /// 文字遣い種別（新字新仮名 など）。
    public let kanaType: String?
    /// 作品に著作権が残っているか。
    public let copyright: Bool
    public let releaseDate: String?
    public let cardUrl: String?
    /// テキストファイル（zip）の URL。持たない作品もある。
    public let textUrl: String?
    public let htmlUrl: String?
    /// 著者・翻訳者など、この作品に関わった人物。
    ///
    /// 並びは role の文字列順・人物IDの昇順で、役割の重要度順ではない。
    public let contributors: [ContributorResponse]

    public init(
        id: Int,
        title: String,
        titleKana: String? = nil,
        subtitle: String? = nil,
        firstAppearance: String? = nil,
        ndc: String? = nil,
        kanaType: String? = nil,
        copyright: Bool,
        releaseDate: String? = nil,
        cardUrl: String? = nil,
        textUrl: String? = nil,
        htmlUrl: String? = nil,
        contributors: [ContributorResponse]
    ) {
        self.id = id
        self.title = title
        self.titleKana = titleKana
        self.subtitle = subtitle
        self.firstAppearance = firstAppearance
        self.ndc = ndc
        self.kanaType = kanaType
        self.copyright = copyright
        self.releaseDate = releaseDate
        self.cardUrl = cardUrl
        self.textUrl = textUrl
        self.htmlUrl = htmlUrl
        self.contributors = contributors
    }
}
