import AozoraAPIResponse
import SwiftUI

/// 作品を特定するもの。値を持たない項目は行ごと省く。
struct TitleSection: View {
    static let roleOrder = ["著者", "翻訳者", "編者", "校訂者"]

    let book: BookResponse

    var body: some View {
        Section {
            LabeledContent("作品名", value: book.title)
            if let subtitle = book.subtitle {
                LabeledContent("副題", value: subtitle)
            }
            if let titleKana = book.titleKana, titleKana != book.title {
                LabeledContent("作品名読み", value: titleKana)
            }

            ForEach(contributors) { contributor in
                ContributorRow(contributor: contributor)
            }
        }
    }

    /// 関係者は役割の文字列順で届くので（「翻訳者」が「著者」より先に来る）、著者から並べ直す。
    private var contributors: [ContributorResponse] {
        book.contributors.enumerated()
            .sorted { (rank(of: $0.element.role), $0.offset) < (rank(of: $1.element.role), $1.offset) }
            .map(\.element)
    }

    private func rank(of role: String) -> Int {
        Self.roleOrder.firstIndex(of: role) ?? Self.roleOrder.count
    }
}
