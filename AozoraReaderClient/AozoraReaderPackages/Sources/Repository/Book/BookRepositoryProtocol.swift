import AozoraAPIResponse

/// 作品を取ってくる窓口。
public protocol BookRepositoryProtocol: Sendable {
    /// 作品を一覧・検索する。
    func books(title: String?, author: String?, personId: Int?, limit: Int, offset: Int) async throws -> BookPageResponse

    /// 作品を 1 件取得する。
    func book(id: Int) async throws -> BookResponse
}
