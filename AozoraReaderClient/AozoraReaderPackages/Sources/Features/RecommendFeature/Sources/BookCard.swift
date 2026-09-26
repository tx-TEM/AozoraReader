import AozoraAPIResponse
import Routing
import SwiftUI

/// おすすめの作品 1 件。本の表紙に見立てて作品名を載せ、その下に著者名を出す。
/// タップすると詳細へ行く。
struct BookCard: View {
    static let coverWidth: CGFloat = 116
    static let coverHeight: CGFloat = 168

    let book: BookSummaryResponse

    var body: some View {
        NavigationLink(value: Destination.book(id: book.id)) {
            VStack(alignment: .leading, spacing: 8) {
                BookCover(title: book.title, color: CoverColor.of(bookId: book.id))
                    .frame(width: Self.coverWidth, height: Self.coverHeight)

                Text(book.contributors.map(\.name).joined(separator: "、"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .frame(width: Self.coverWidth, alignment: .leading)
            }
        }
        .buttonStyle(.plain)
    }
}

/// 表紙。単色の地に明朝体で作品名を置き、背の側に影を落として本らしく見せる。
private struct BookCover: View {
    let title: String
    let color: Color

    var body: some View {
        ZStack(alignment: .topLeading) {
            color

            // 背表紙のふくらみ
            LinearGradient(
                colors: [.black.opacity(0.25), .clear],
                startPoint: .leading,
                endPoint: .init(x: 0.12, y: 0.5)
            )

            VStack(alignment: .leading, spacing: 8) {
                Rectangle()
                    .fill(.white.opacity(0.6))
                    .frame(width: 20, height: 1)

                Text(title)
                    .font(.system(.subheadline, design: .serif, weight: .semibold))
                    .foregroundStyle(.white)
                    .lineLimit(5)
            }
            .padding(.leading, 16)
            .padding([.top, .trailing], 12)
        }
        .clipShape(.rect(cornerRadii: .init(topLeading: 2, bottomLeading: 2, bottomTrailing: 6, topTrailing: 6)))
        .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)
    }
}

/// 表紙の色。落ち着いた和色から、作品ごとに決まった色を選ぶ。
private enum CoverColor {
    private static let palette: [Color] = [
        Color(red: 0.15, green: 0.25, blue: 0.40), // 藍
        Color(red: 0.55, green: 0.18, blue: 0.20), // 臙脂
        Color(red: 0.25, green: 0.38, blue: 0.27), // 松葉
        Color(red: 0.36, green: 0.30, blue: 0.42), // 紫紺
        Color(red: 0.55, green: 0.40, blue: 0.20), // 朽葉
        Color(red: 0.12, green: 0.38, blue: 0.43), // 納戸
    ]

    static func of(bookId: Int) -> Color {
        palette[bookId % palette.count]
    }
}
