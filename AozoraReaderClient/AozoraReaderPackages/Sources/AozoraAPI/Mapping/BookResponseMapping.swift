import AozoraAPIResponse

internal extension BookResponse {
    init(response: Components.Schemas.Book) {
        self.init(
            id: response.id,
            title: response.title,
            titleKana: response.titleKana,
            subtitle: response.subtitle,
            firstAppearance: response.firstAppearance,
            ndc: response.ndc,
            kanaType: response.kanaType,
            copyright: response.copyright,
            releaseDate: response.releaseDate,
            cardUrl: response.cardUrl,
            textUrl: response.textUrl,
            htmlUrl: response.htmlUrl,
            contributors: response.contributors.map(ContributorResponse.init(response:))
        )
    }
}
