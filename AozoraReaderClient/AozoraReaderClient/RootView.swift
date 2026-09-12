import BrowseFeature
import SwiftUI

/// タブ画面。個別の画面を載せるための器。
struct RootView: View {
    var body: some View {
        TabView {
            BrowseView()
                .tabItem { Label("さがす", systemImage: "magnifyingglass") }
        }
    }
}
