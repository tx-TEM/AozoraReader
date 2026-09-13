import SwiftUI

/// 本文を青空文庫の HTML のまま読む画面。
public struct ReaderView: View {
    private let url: URL

    public init(url: URL) {
        self.url = url
    }

    public var body: some View {
        WebView(url: url)
            .navigationBarTitleDisplayMode(.inline)
            // 本文にタブバーが被るので、読んでいるあいだは隠す。
            .toolbar(.hidden, for: .tabBar)
    }
}
