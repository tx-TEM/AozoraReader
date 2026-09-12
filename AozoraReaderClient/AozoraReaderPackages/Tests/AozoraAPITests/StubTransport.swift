import AozoraAPI
import Foundation
import HTTPTypes
import OpenAPIRuntime

/// 決め打ちの JSON を 200 で返す transport。送られたリクエストを記録する。
struct StubTransport: ClientTransport {
    let json: String
    var recorder: RequestRecorder?

    func send(
        _ request: HTTPRequest,
        body: HTTPBody?,
        baseURL: URL,
        operationID: String
    ) async throws -> (HTTPResponse, HTTPBody?) {
        await recorder?.record(request)
        var response = HTTPResponse(status: .ok)
        response.headerFields[.contentType] = "application/json"
        return (response, HTTPBody(json))
    }
}

actor RequestRecorder {
    private(set) var lastPath: String?

    func record(_ request: HTTPRequest) { lastPath = request.path }
}

extension AozoraAPIClient {
    static func stub(returning json: String, recorder: RequestRecorder? = nil) -> AozoraAPIClient {
        AozoraAPIClient(transport: StubTransport(json: json, recorder: recorder))
    }
}
