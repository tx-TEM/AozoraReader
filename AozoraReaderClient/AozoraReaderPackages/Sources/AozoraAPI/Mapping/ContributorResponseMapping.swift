import AozoraAPIResponse

internal extension ContributorResponse {
    init(response: Components.Schemas.Contributor) {
        self.init(
            personId: response.personId,
            name: response.name,
            role: response.role,
            birthDate: response.birthDate,
            deathDate: response.deathDate
        )
    }
}
