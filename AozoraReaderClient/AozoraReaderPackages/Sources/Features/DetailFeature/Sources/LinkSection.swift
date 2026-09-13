import AozoraAPIResponse
import SwiftUI

struct LinkSection: View {
    let book: BookResponse

    var body: some View {
        Section {
            if canRead {
                Button("読む") {}
            }
            if let url = book.cardUrl.flatMap(URL.init(string:)) {
                Link("図書カードを開く", destination: url)
            }
        }
    }

    /// 本文のファイルを持たない作品は読めない。
    private var canRead: Bool {
        book.textUrl != nil || book.htmlUrl != nil
    }
}
