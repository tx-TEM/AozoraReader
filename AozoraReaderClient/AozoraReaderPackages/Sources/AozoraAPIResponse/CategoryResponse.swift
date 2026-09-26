/// NDC の類。分類番号の無い作品は「その他」に入る。
public struct CategoryResponse: Sendable, Hashable, Identifiable {
    /// 類の番号（`9`）。その他は `other`。
    public let id: String
    /// NDC 標準の類名（文学 など）。
    public let name: String

    public init(id: String, name: String) {
        self.id = id
        self.name = name
    }
}
