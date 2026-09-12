import BrowseFeature
import Routing
import SwiftUI

/// タブ画面。個別の画面を載せるための器。
struct RootView: View {
    @State private var router = Router()

    var body: some View {
        TabView {
            NavigationStack(path: $router.path) {
                BrowseView()
                    .withAppRouter()
            }
            .tabItem { Label("さがす", systemImage: "magnifyingglass") }
        }
    }
}
