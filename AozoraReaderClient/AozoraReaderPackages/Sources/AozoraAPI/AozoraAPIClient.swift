import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

/// 生成されたクライアントを抱える器。
public struct AozoraAPIClient: Sendable {
    internal let client: Client

    public init(serverURL: URL, transport: any ClientTransport = URLSessionTransport()) {
        client = Client(serverURL: serverURL, transport: transport)
    }
}
