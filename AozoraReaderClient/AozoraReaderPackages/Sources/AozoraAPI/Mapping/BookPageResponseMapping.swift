import AozoraAPIResponse

internal extension BookPageResponse {
    init(response: Components.Schemas.BookPage) {
        self.init(
            total: response.total,
            limit: response.limit,
            offset: response.offset,
            items: response.items.map(BookResponse.init(response:))
        )
    }
}
