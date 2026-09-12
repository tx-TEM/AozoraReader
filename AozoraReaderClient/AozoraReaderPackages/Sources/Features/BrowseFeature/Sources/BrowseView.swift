import SwiftUI
import UIComponents

/// さがすタブ。作品の一覧を絞り込んで探す。
public struct BrowseView: View {
    @State private var model: BrowseViewModel

    public init(model: BrowseViewModel = BrowseViewModel()) {
        _model = State(initialValue: model)
    }

    public var body: some View {
        VStack(spacing: 0) {
            SearchBar(
                text: $model.keyword,
                isComposing: $model.isComposing,
                placeholder: "作品名で絞り込む"
            )

            List(model.books) { book in
                BookRow(book: book)
            }
            .dismissesKeyboardOnInteraction()
        }
        .task { await model.task() }
    }
}
