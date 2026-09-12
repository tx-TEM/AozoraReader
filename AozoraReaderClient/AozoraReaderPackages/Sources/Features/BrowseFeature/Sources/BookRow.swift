import AozoraAPIResponse
import Routing
import SwiftUI

/// 作品リストの 1 件。
///
/// 副題を持たない作品では、副題を行から省く。
struct BookRow: View {
    let book: BookSummaryResponse

    var body: some View {
        NavigationLink(value: Destination.book(id: book.id)) {
            content
        }
    }

    private var content: some View {
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
}
