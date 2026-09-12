import SwiftUI

/// さがすタブ。作品の一覧を絞り込んで探す。
public struct BrowseView: View {
    @State private var model: BrowseViewModel

    public init(model: BrowseViewModel = BrowseViewModel()) {
        _model = State(initialValue: model)
    }

    public var body: some View {
        List(model.books) { book in
            BookRow(book: book)
        }
        .task { await model.load() }
    }
}
