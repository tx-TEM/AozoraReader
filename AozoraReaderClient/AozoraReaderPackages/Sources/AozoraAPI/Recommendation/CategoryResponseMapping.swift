import AozoraAPIResponse

internal extension CategoryResponse {
    init(response: Components.Schemas.Category) {
        self.init(id: response.id, name: response.name)
    }
}
