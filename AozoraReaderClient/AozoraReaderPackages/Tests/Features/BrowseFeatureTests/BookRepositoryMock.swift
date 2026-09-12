import AozoraAPIResponse
import Foundation
import Repository

@MainActor
final class BookRepositoryMock: BookRepositoryProtocol {
    struct Call: Equatable {
        let title: String?
        let author: String?
        let offset: Int
    }

    private(set) var calls: [Call] = []
    var items: [BookSummaryResponse] = []
    /// 応答を遅らせる。取得中のふるまいを見るために使う。
    var delay: Duration = .zero

    nonisolated init() {}

    func book(id: Int) async throws -> BookResponse {
        BookResponse(id: id, title: "", copyright: false, contributors: [])
    }

    func books(
        title: String?,
        author: String?,
        personId: Int?,
        limit: Int,
        offset: Int
    ) async throws -> BookPageResponse {
        calls.append(Call(title: title, author: author, offset: offset))
        if delay > .zero {
            try await Task.sleep(for: delay)
        }
        return BookPageResponse(total: items.count, limit: limit, offset: offset, items: items)
    }
}

extension BookSummaryResponse {
    static func stub(id: Int, title: String) -> BookSummaryResponse {
        BookSummaryResponse(id: id, title: title, contributors: [])
    }
}
