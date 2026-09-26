import AozoraAPIResponse

internal extension ContributorSummaryResponse {
    init(response: Components.Schemas.ContributorSummary) {
        self.init(personId: response.personId, name: response.name, role: response.role)
    }
}
