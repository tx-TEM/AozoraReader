import AozoraAPIResponse
import Routing
import SwiftUI

struct LinkSection: View {
    let book: BookResponse

    var body: some View {
        Section {
            // 本文の HTML を持たない作品は読めない。
            if let htmlUrl = book.htmlUrl.flatMap(URL.init(string:)) {
                NavigationLink("読む", value: Destination.reader(url: htmlUrl))
                    .accessibilityIdentifier("detail.readButton")
            }
            if let cardUrl = book.cardUrl.flatMap(URL.init(string:)) {
                Link("図書カードを開く", destination: cardUrl)
                    .accessibilityIdentifier("detail.cardLink")
            }
        }
    }
}
