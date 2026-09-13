import SwiftUI
import UIComponents

/// さがすタブ。作品の一覧を絞り込んで探す。
public struct BrowseView: View {
    @State private var model: BrowseViewModel

    public init(model: BrowseViewModel = BrowseViewModel()) {
        _model = State(initialValue: model)
    }

    public var body: some View {
        List(model.books) { book in
            BookRow(book: book)
                .task { await model.rowAppeared(book) }
        }
        .safeAreaInset(edge: .top) {
            VStack(spacing: 0) {
                SearchBar(
                    text: $model.keyword,
                    isComposing: $model.isComposing,
                    placeholder: model.target.placeholder
                )
                Picker("絞り込み対象", selection: $model.target) {
                    ForEach(FilterTarget.allCases, id: \.self) { target in
                        Text(target.name).tag(target)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.bottom, 8)
            }
            .background(.bar)
        }
        .dismissesKeyboardOnInteraction()
        .task { await model.task() }
    }
}
