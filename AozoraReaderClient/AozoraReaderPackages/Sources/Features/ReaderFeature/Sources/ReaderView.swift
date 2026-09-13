import SwiftUI
import UIComponents

/// 本文を青空文庫の HTML のまま読む画面。
public struct ReaderView: View {
    private let url: URL
    @State private var hasFailed = false

    public init(url: URL) {
        self.url = url
    }

    public var body: some View {
        content
            .navigationBarTitleDisplayMode(.inline)
            // 本文にタブバーが被るので、読んでいるあいだは隠す。
            .toolbar(.hidden, for: .tabBar)
    }

    @ViewBuilder
    private var content: some View {
        if hasFailed {
            ErrorView { hasFailed = false }
        } else {
            WebView(url: url, hasFailed: $hasFailed)
        }
    }
}
