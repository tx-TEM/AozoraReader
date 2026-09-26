/// 作品を並べて出すときの関係者。詳細は ``ContributorResponse``。
public struct ContributorSummaryResponse: Sendable, Hashable, Identifiable {
    public var id: Int { personId }

    public let personId: Int
    /// 姓名を半角スペースで連結したもの。
    public let name: String
    /// 役割フラグ（著者 / 翻訳者 / 校訂者 / 編者 / その他）。
    public let role: String

    public init(personId: Int, name: String, role: String) {
        self.personId = personId
        self.name = name
        self.role = role
    }
}
