import AozoraAPIResponse
import Routing
import SwiftUI
import UIComponents

/// 作品の詳細画面。
public struct DetailView: View {
    static let roleOrder = ["著者", "翻訳者", "編者", "校訂者"]

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
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier("detail")
    }

    @ViewBuilder
    private var content: some View {
        if model.hasFailed {
            ErrorView(reloadIdentifier: "detail.error.reload_button") {
                Task { await model.task() }
            }
        } else {
            List {
                if let book = model.book {
                    titleSection(of: book)
                    bibliographySection(of: book)
                    linkSection(of: book)
                }
            }
        }
    }
}

// MARK: - 作品を特定するもの

extension DetailView {
    /// 値を持たない項目は行ごと省く。
    private func titleSection(of book: BookResponse) -> some View {
        Section {
            LabeledContent("作品名", value: book.title)
            if let subtitle = book.subtitle {
                LabeledContent("副題", value: subtitle)
            }
            if let titleKana = book.titleKana, titleKana != book.title {
                LabeledContent("作品名読み", value: titleKana)
            }

            ForEach(contributors(of: book)) { contributor in
                contributorRow(of: contributor)
            }
        }
    }

    /// 関係者 1 人。役割を問わず出す。
    private func contributorRow(of contributor: ContributorResponse) -> some View {
        LabeledContent {
            Text(contributor.name)
            if let years = years(of: contributor) {
                Text(years).font(.caption)
            }
        } label: {
            Text(contributor.role)
        }
    }

    /// 関係者は役割の文字列順で届くので（「翻訳者」が「著者」より先に来る）、著者から並べ直す。
    private func contributors(of book: BookResponse) -> [ContributorResponse] {
        book.contributors.enumerated()
            .sorted { (rank(of: $0.element.role), $0.offset) < (rank(of: $1.element.role), $1.offset) }
            .map(\.element)
    }

    private func rank(of role: String) -> Int {
        Self.roleOrder.firstIndex(of: role) ?? Self.roleOrder.count
    }

    /// 生没年。月日まで出すと読みにくいので年だけにする。片方だけ欠けることがある。
    private func years(of contributor: ContributorResponse) -> String? {
        let birth = contributor.birthDate.map { String($0.prefix(4)) }
        let death = contributor.deathDate.map { String($0.prefix(4)) }
        guard birth != nil || death != nil else { return nil }
        return "\(birth ?? "") - \(death ?? "")"
    }
}

// MARK: - 書誌

extension DetailView {
    /// 値を持たない項目は行ごと省く。
    private func bibliographySection(of book: BookResponse) -> some View {
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

// MARK: - リンク

extension DetailView {
    private func linkSection(of book: BookResponse) -> some View {
        Section {
            // 本文の HTML を持たない作品は読めない。
            if let htmlUrl = book.htmlUrl.flatMap(URL.init(string:)) {
                NavigationLink("読む", value: Destination.reader(url: htmlUrl))
                    .accessibilityIdentifier("detail.read_button")
            }
            if let cardUrl = book.cardUrl.flatMap(URL.init(string:)) {
                Link("図書カードを開く", destination: cardUrl)
                    .accessibilityIdentifier("detail.card_link")
            }
        }
    }
}
