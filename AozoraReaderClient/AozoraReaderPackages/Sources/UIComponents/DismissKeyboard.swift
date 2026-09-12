import SwiftUI
import UIKit

extension View {
    /// スクロールでキーボードを閉じる。
    ///
    /// `scrollDismissesKeyboard` は使えない。SwiftUI のフォーカスを見ているため、
    /// ``SearchBar`` のように `UIViewRepresentable` の中が first responder に
    /// なっている場合は閉じるものが無い。
    ///
    /// タップでは閉じない。`TapGesture` を足すと、`simultaneousGesture` でも
    /// `List` の行のタップを食って遷移しなくなる。行以外の余白はほとんど無いので、
    /// 実際に困る場面は少ない。
    public func dismissesKeyboardOnInteraction() -> some View {
        simultaneousGesture(
            DragGesture(minimumDistance: 10).onChanged { _ in
                UIApplication.shared.endEditing()
            }
        )
    }
}

private extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
