import AozoraAPIResponse
import Repository
import SwiftUI

/// さがすタブ。作品の一覧を絞り込んで探す。
public struct BrowseView: View {
    private let repository: any BookRepositoryProtocol

    @State private var books: [BookResponse] = []

    public init(repository: any BookRepositoryProtocol = BookRepository()) {
        self.repository = repository
    }

    public var body: some View {
        List(books) { book in
            VStack(alignment: .leading, spacing: 2) {
                Text(book.title)
                if let subtitle = book.subtitle {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Text(book.contributors.map(\.name).joined(separator: "、"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .task {
            books = (try? await repository.books(title: nil, author: nil, personId: nil, limit: 50, offset: 0))?.items ?? []
        }
    }
}
