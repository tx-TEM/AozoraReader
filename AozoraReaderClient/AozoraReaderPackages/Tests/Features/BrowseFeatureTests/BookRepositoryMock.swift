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
    var items: [BookResponse] = []
    /// 応答を遅らせる。取得中のふるまいを見るために使う。
    var delay: Duration = .zero

    nonisolated init() {}

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

extension BookResponse {
    static func stub(id: Int, title: String) -> BookResponse {
        BookResponse(id: id, title: title, copyright: false, contributors: [])
    }
}
