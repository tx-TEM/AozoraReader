/// API へのリクエスト。
///
/// パラメータを持つ値として作り、``response(api:)`` に渡したクライアントで送る。
/// クライアントを外から渡すので、テストでは通信を差し替えたクライアントを渡せる。
/// どのエンドポイントもこの形で呼べるように、このプロトコルで形をそろえている。
public protocol AozoraAPIRequest: Sendable {
    /// 受け取る結果の型。
    associatedtype Response: Sendable

    /// リクエストを送り、レスポンスをアプリの型に変えて返す。
    @concurrent
    func response(api: AozoraAPIClient) async throws -> Response
}
