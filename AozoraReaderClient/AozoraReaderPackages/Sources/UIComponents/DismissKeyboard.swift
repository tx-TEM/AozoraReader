import SwiftUI
import UIKit

extension View {
    /// スクロールと、入力欄以外へのタップでキーボードを閉じる。
    ///
    /// `scrollDismissesKeyboard` は使えない。SwiftUI のフォーカスを見ているため、
    /// ``SearchBar`` のように `UIViewRepresentable` の中が first responder に
    /// なっている場合は閉じるものが無い。
    public func dismissesKeyboardOnInteraction() -> some View {
        simultaneousGesture(
            DragGesture(minimumDistance: 10).onChanged { _ in
                UIApplication.shared.endEditing()
            }
        )
        .simultaneousGesture(
            TapGesture().onEnded {
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
