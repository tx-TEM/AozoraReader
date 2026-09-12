import SwiftUI

/// 作品の詳細画面。
public struct DetailView: View {
    private let bookId: Int

    public init(bookId: Int) {
        self.bookId = bookId
    }

    public var body: some View {
        Text("\(bookId)")
    }
}
