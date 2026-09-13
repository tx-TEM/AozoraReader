import SwiftUI
import UIComponents

/// 作品の詳細画面。
public struct DetailView: View {
    @State private var model: DetailViewModel

    public init(bookId: Int) {
        _model = State(initialValue: DetailViewModel(bookId: bookId))
    }

    public init(model: DetailViewModel) {
        _model = State(initialValue: model)
    }

    public var body: some View {
        content
            .task { await model.task() }
    }

    @ViewBuilder
    private var content: some View {
        if model.hasFailed {
            ErrorView { Task { await model.task() } }
        } else {
            List {
                if let book = model.book {
                    TitleSection(book: book)
                    BibliographySection(book: book)
                    LinkSection(book: book)
                }
            }
        }
    }
}
