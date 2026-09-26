/// 1 カテゴリー分のおすすめ。
public struct RecommendationSectionResponse: Sendable, Hashable, Identifiable {
    public var id: String { category.id }

    public let category: CategoryResponse
    /// このカテゴリーからランダムに選んだ最大 10 件。
    public let books: [BookSummaryResponse]

    public init(category: CategoryResponse, books: [BookSummaryResponse]) {
        self.category = category
        self.books = books
    }
}
