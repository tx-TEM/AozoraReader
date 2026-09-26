import AozoraAPIResponse

internal extension RecommendationsResponse {
    init(response: Components.Schemas.Recommendations) {
        self.init(sections: response.sections.map(RecommendationSectionResponse.init(response:)))
    }
}
