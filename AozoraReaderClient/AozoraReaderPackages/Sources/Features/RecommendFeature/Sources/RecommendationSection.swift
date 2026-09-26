import AozoraAPIResponse
import SwiftUI

/// 1 カテゴリー分のセクション。見出しの下に作品を横スクロールで並べ、末尾に「もっと見る」を置く。
struct RecommendationSection: View {
    let section: RecommendationSectionResponse

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(section.category.name)
                .font(.title3.bold())
                .padding(.horizontal)

            ScrollView(.horizontal) {
                LazyHStack(alignment: .top, spacing: 16) {
                    ForEach(section.books) { book in
                        BookCard(book: book)
                            .accessibilityIdentifier("recommend.book.\(book.title)")
                    }
                    MoreButton()
                        .accessibilityIdentifier("recommend.more_button")
                }
                .scrollTargetLayout()
            }
            .contentMargins(.horizontal, 16, for: .scrollContent)
            .scrollTargetBehavior(.viewAligned)
            .scrollIndicators(.hidden)
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier("recommend.carousel.\(section.category.name)")
        }
    }
}

/// カルーセルの末尾に置く。行き先のカテゴリーの一覧はまだ無いので、押しても何も起きない。
private struct MoreButton: View {
    var body: some View {
        Button {} label: {
            VStack(spacing: 8) {
                Image(systemName: "chevron.right")
                    .font(.body.weight(.semibold))
                    .frame(width: 48, height: 48)
                    .background(.fill.tertiary, in: .circle)
                Text("もっと見る")
                    .font(.caption)
            }
            .frame(width: 88, height: BookCard.coverHeight)
        }
        .buttonStyle(.plain)
        .foregroundStyle(.tint)
    }
}
