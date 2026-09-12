import AozoraAPI
import Foundation
import HTTPTypes
import OpenAPIRuntime

/// 決め打ちの JSON を 200 で返す transport。
struct StubTransport: ClientTransport {
    let json: String

    func send(
        _ request: HTTPRequest,
        body: HTTPBody?,
        baseURL: URL,
        operationID: String
    ) async throws -> (HTTPResponse, HTTPBody?) {
        var response = HTTPResponse(status: .ok)
        response.headerFields[.contentType] = "application/json"
        return (response, HTTPBody(json))
    }
}

extension AozoraAPIClient {
    static func stub(returning json: String) -> AozoraAPIClient {
        AozoraAPIClient(transport: StubTransport(json: json))
    }
}
