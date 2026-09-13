import AozoraAPIResponse
import SwiftUI

/// 書誌。値を持たない項目は行ごと省く。
struct BibliographySection: View {
    let book: BookResponse

    var body: some View {
        Section {
            row("分類番号", book.ndc)
            row("文字遣い", book.kanaType)
            row("公開日", book.releaseDate)
            LabeledContent("著作権", value: book.copyright ? "保護期間中" : "保護期間満了")
            longRow("初出", book.firstAppearance)
        }
    }

    @ViewBuilder
    private func row(_ label: String, _ value: String?) -> some View {
        if let value {
            LabeledContent(label, value: value)
        }
    }

    /// 1 行に収まらない値。ラベルの右に置くと折り返して読めないので、下に敷く。
    @ViewBuilder
    private func longRow(_ label: String, _ value: String?) -> some View {
        if let value {
            VStack(alignment: .leading, spacing: 4) {
                Text(label)
                Text(value).foregroundStyle(.secondary)
            }
        }
    }
}
