import SwiftUI
import UIKit

/// 検索バー。
///
/// SwiftUI の `TextField` / `.searchable` では 2 つのことができないため、
/// `UISearchBar` を包んでいる。
///
/// - 日本語入力が変換中かどうかを知る（`markedTextRange`）
/// - 入力欄の中にスピナーを出す
public struct SearchBar: UIViewRepresentable {
    @Binding private var text: String
    /// 変換が確定していない文字列を編集中かどうか。
    @Binding private var isComposing: Bool

    private let placeholder: String
    private let isLoading: Bool
    /// 検索キーをたたいたときに呼ぶ。
    private let onSubmit: () -> Void

    public init(
        text: Binding<String>,
        isComposing: Binding<Bool>,
        placeholder: String = "",
        isLoading: Bool = false,
        onSubmit: @escaping () -> Void = {}
    ) {
        _text = text
        _isComposing = isComposing
        self.placeholder = placeholder
        self.isLoading = isLoading
        self.onSubmit = onSubmit
    }

    public func makeUIView(context: Context) -> UISearchBar {
        let searchBar = UISearchBar()
        searchBar.delegate = context.coordinator
        searchBar.searchBarStyle = .minimal
        searchBar.autocapitalizationType = .none
        searchBar.returnKeyType = .search
        return searchBar
    }

    public func updateUIView(_ searchBar: UISearchBar, context: Context) {
        context.coordinator.parent = self

        // 変換中に text を書き戻すと、入力中の文字が確定されてしまう。
        if searchBar.searchTextField.markedTextRange == nil, searchBar.text != text {
            searchBar.text = text
        }

        searchBar.placeholder = placeholder
        context.coordinator.setLoading(isLoading, on: searchBar)
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    public final class Coordinator: NSObject, UISearchBarDelegate {
        fileprivate var parent: SearchBar
        /// 虫眼鏡アイコン。スピナーと差し替えるため保持する。
        private var magnifier: UIView?

        fileprivate init(parent: SearchBar) {
            self.parent = parent
        }

        public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            parent.text = searchText
            parent.isComposing = searchBar.searchTextField.markedTextRange != nil
        }

        public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            searchBar.resignFirstResponder()
            parent.onSubmit()
        }

        fileprivate func setLoading(_ isLoading: Bool, on searchBar: UISearchBar) {
            let field = searchBar.searchTextField

            if magnifier == nil, !(field.leftView is UIActivityIndicatorView) {
                magnifier = field.leftView
            }

            if isLoading {
                guard !(field.leftView is UIActivityIndicatorView) else { return }
                let indicator = UIActivityIndicatorView(style: .medium)
                indicator.startAnimating()
                field.leftView = indicator
            } else if field.leftView is UIActivityIndicatorView {
                field.leftView = magnifier
            }
        }
    }
}
