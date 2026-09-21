import SwiftUI

/// 取得に失敗したときに出す。文言の下に再読み込みボタンを置き、画面の中央に寄せる。
public struct ErrorView: View {
    private let message: String
    /// 再読み込みボタンに振る accessibilityIdentifier。
    private let reloadIdentifier: String?
    private let reload: () -> Void

    public init(
        message: String = "通信に失敗しました",
        reloadIdentifier: String? = nil,
        reload: @escaping () -> Void
    ) {
        self.message = message
        self.reloadIdentifier = reloadIdentifier
        self.reload = reload
    }

    public var body: some View {
        VStack(spacing: 16) {
            Text(message)
                .foregroundStyle(.secondary)
            reloadButton
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    @ViewBuilder
    private var reloadButton: some View {
        if let reloadIdentifier {
            button.accessibilityIdentifier(reloadIdentifier)
        } else {
            button
        }
    }

    private var button: some View {
        Button("再読み込み", action: reload)
            .buttonStyle(.bordered)
    }
}
