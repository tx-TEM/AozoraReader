import AozoraAPIResponse

/// 作品を取ってくる窓口。
public protocol BookRepositoryProtocol: Sendable {
    /// 作品を一覧・検索する。
    func books(q: String?, personId: Int?, limit: Int, offset: Int) async throws -> BookPageResponse
}
