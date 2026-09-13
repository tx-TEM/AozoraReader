import SwiftUI

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
        List {
            if let book = model.book {
                TitleSection(book: book)
                BibliographySection(book: book)
                LinkSection(book: book)
            }
        }
        .task { await model.task() }
    }
}
