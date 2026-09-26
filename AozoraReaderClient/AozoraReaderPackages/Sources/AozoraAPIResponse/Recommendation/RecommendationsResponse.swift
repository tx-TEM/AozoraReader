/// おすすめのセクション。並びはサーバーが返した順。
public struct RecommendationsResponse: Sendable, Hashable {
    public let sections: [RecommendationSectionResponse]

    public init(sections: [RecommendationSectionResponse]) {
        self.sections = sections
    }
}
