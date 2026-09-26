import AozoraAPIResponse
import Routing
import SwiftUI
import UIComponents

/// さがすタブ。作品の一覧を絞り込んで探す。
public struct BrowseView: View {
    @State private var model: BrowseViewModel

    public init(model: BrowseViewModel = BrowseViewModel()) {
        _model = State(initialValue: model)
    }

    public var body: some View {
        content
            .safeAreaInset(edge: .top) { filter }
            .dismissesKeyboardOnInteraction()
            .task { await model.task() }
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier("browse")
    }

    @ViewBuilder
    private var content: some View {
        if model.hasFailed {
            ErrorView(reloadIdentifier: "browse.error.reload_button") {
                Task { await model.task() }
            }
        } else {
            List(model.books) { book in
                NavigationLink(value: Destination.book(id: book.id)) {
                    row(of: book)
                }
                .accessibilityIdentifier("browse.book_row.\(book.title)")
                .task { await model.rowAppeared(book) }
            }
        }
    }
}

// MARK: - 作品の行

extension BrowseView {
    /// 作品リストの 1 件。副題を持たない作品では、副題を行から省く。
    private func row(of book: BookSummaryResponse) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(book.title)

            if let subtitle = book.subtitle {
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Text(book.contributors.map(\.name).joined(separator: "、"))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - 絞り込み

extension BrowseView {
    private var filter: some View {
        VStack(spacing: 0) {
            SearchBar(
                text: $model.keyword,
                isComposing: $model.isComposing,
                placeholder: model.target.placeholder,
                identifier: "browse.search_field",
                onSubmit: { model.submit() }
            )
            Picker("絞り込み対象", selection: $model.target) {
                ForEach(FilterTarget.allCases, id: \.self) { target in
                    Text(target.name)
                        .accessibilityIdentifier(identifier(for: target))
                        .tag(target)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
        .background(.bar)
    }

    private func identifier(for target: FilterTarget) -> String {
        switch target {
        case .title: "browse.target_picker.title"
        case .author: "browse.target_picker.author"
        }
    }
}
