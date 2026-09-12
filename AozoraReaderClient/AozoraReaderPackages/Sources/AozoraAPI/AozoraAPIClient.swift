import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

/// 生成されたクライアントを抱える器。
public struct AozoraAPIClient: Sendable {
    internal let client: Client

    /// 接続先は openapi.yaml の `servers:` から生成されたものを使う。
    public init(transport: any ClientTransport = URLSessionTransport()) {
        client = Client(serverURL: try! Servers.Server1.url(), transport: transport)
    }
}
