import AozoraAPIResponse
import Routing
import SwiftUI
import UIComponents

/// おすすめタブ。カテゴリーごとに作品を横に並べる。
public struct RecommendView: View {
    static let coverWidth: CGFloat = 116
    static let coverHeight: CGFloat = 168

    @State private var model: RecommendViewModel

    public init(model: RecommendViewModel = RecommendViewModel()) {
        _model = State(initialValue: model)
    }

    public var body: some View {
        content
            .navigationTitle("おすすめ")
            .task { await model.task() }
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier("recommend")
    }

    @ViewBuilder
    private var content: some View {
        if model.hasFailed {
            ErrorView(reloadIdentifier: "recommend.error.reload_button") {
                Task { await model.reload() }
            }
        } else {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 32) {
                    ForEach(model.sections) { section in
                        carousel(of: section)
                    }
                }
                .padding(.vertical)
            }
        }
    }
}

// MARK: - カルーセル

extension RecommendView {
    /// 1 カテゴリー分。見出しの下に作品を横スクロールで並べ、末尾に「もっと見る」を置く。
    private func carousel(of section: RecommendationSectionResponse) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(section.category.name)
                .font(.title3.bold())
                .padding(.horizontal)

            ScrollView(.horizontal) {
                LazyHStack(alignment: .top, spacing: 16) {
                    ForEach(section.books) { book in
                        NavigationLink(value: Destination.book(id: book.id)) {
                            card(of: book)
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("recommend.book.\(book.title)")
                    }
                    moreButton
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

    /// カルーセルの末尾に置く。行き先のカテゴリーの一覧はまだ無いので、押しても何も起きない。
    private var moreButton: some View {
        Button {} label: {
            VStack(spacing: 8) {
                Image(systemName: "chevron.right")
                    .font(.body.weight(.semibold))
                    .frame(width: 48, height: 48)
                    .background(.fill.tertiary, in: .circle)
                Text("もっと見る")
                    .font(.caption)
            }
            .frame(width: 88, height: Self.coverHeight)
        }
        .buttonStyle(.plain)
        .foregroundStyle(.tint)
    }
}

// MARK: - 作品のカード

extension RecommendView {
    /// 本の表紙に見立てて作品名を載せ、その下に著者名を出す。
    private func card(of book: BookSummaryResponse) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            cover(of: book)
                .frame(width: Self.coverWidth, height: Self.coverHeight)

            Text(book.contributors.map(\.name).joined(separator: "、"))
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .frame(width: Self.coverWidth, alignment: .leading)
        }
    }

    /// 単色の地に明朝体で作品名を置き、背の側に影を落として本らしく見せる。
    private func cover(of book: BookSummaryResponse) -> some View {
        ZStack(alignment: .topLeading) {
            CoverColor.of(bookId: book.id)

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

                Text(book.title)
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
