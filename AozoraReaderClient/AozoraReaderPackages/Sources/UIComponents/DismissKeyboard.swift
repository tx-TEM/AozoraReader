import SwiftUI
import UIKit

extension View {
    /// スクロールと、入力欄以外へのタップでキーボードを閉じる。
    public func dismissesKeyboardOnInteraction() -> some View {
        scrollDismissesKeyboard(.immediately)
            .simultaneousGesture(
                TapGesture().onEnded {
                    UIApplication.shared.sendAction(
                        #selector(UIResponder.resignFirstResponder),
                        to: nil,
                        from: nil,
                        for: nil
                    )
                }
            )
    }
}
