import AozoraAPIResponse

internal extension RecommendationSectionResponse {
    init(response: Components.Schemas.RecommendationSection) {
        self.init(
            category: CategoryResponse(response: response.category),
            books: response.books.map(BookSummaryResponse.init(response:))
        )
    }
}
