import SwiftUI

/// 取得に失敗したときに出す。文言の下に再読み込みボタンを置き、画面の中央に寄せる。
public struct ErrorView: View {
    private let message: String
    private let reload: () -> Void

    public init(message: String = "通信に失敗しました", reload: @escaping () -> Void) {
        self.message = message
        self.reload = reload
    }

    public var body: some View {
        VStack(spacing: 16) {
            Text(message)
                .foregroundStyle(.secondary)
            Button("再読み込み", action: reload)
                .buttonStyle(.bordered)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
