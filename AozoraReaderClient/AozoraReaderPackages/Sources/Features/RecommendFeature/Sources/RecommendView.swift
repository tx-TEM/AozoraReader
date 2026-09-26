import SwiftUI
import UIComponents

/// おすすめタブ。カテゴリーごとに作品を横に並べる。
public struct RecommendView: View {
    @State private var model: RecommendViewModel

    public init(model: RecommendViewModel = RecommendViewModel()) {
        _model = State(initialValue: model)
    }

    public var body: some View {
        content
            .navigationTitle("おすすめ")
            .task { await model.task() }
    }

    @ViewBuilder
    private var content: some View {
        if model.hasFailed {
            ErrorView {
                Task { await model.reload() }
            }
        } else {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 32) {
                    ForEach(model.sections) { section in
                        RecommendationSection(section: section)
                    }
                }
                .padding(.vertical)
            }
        }
    }
}
