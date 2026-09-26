/// 作品の詳細に出す関係者。
public struct ContributorResponse: Sendable, Hashable, Identifiable {
    public var id: Int { personId }

    public let personId: Int
    /// 姓名を半角スペースで連結したもの。
    public let name: String
    /// 役割フラグ（著者 / 翻訳者 / 校訂者 / 編者 / その他）。
    public let role: String
    /// 不明な場合は nil。
    public let birthDate: String?
    /// 不明な場合は nil。
    public let deathDate: String?

    public init(
        personId: Int,
        name: String,
        role: String,
        birthDate: String? = nil,
        deathDate: String? = nil
    ) {
        self.personId = personId
        self.name = name
        self.role = role
        self.birthDate = birthDate
        self.deathDate = deathDate
    }
}
