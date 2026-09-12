/// API の呼び出し 1 本。
public protocol AozoraAPIRequest: Sendable {
    associatedtype Response: Sendable

    func response(api: AozoraAPIClient) async throws -> Response
}
