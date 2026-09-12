import AozoraAPIResponse

internal extension BookSummaryResponse {
    init(response: Components.Schemas.BookSummary) {
        self.init(
            id: response.id,
            title: response.title,
            subtitle: response.subtitle,
            contributors: response.contributors.map(ContributorResponse.init(response:))
        )
    }
}
