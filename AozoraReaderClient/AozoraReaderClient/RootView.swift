import BrowseFeature
import RecommendFeature
import Routing
import SwiftUI

/// タブ画面。個別の画面を載せるための器。
struct RootView: View {
    @State private var browseRouter = Router()
    @State private var recommendRouter = Router()

    var body: some View {
        TabView {
            NavigationStack(path: $browseRouter.path) {
                BrowseView()
                    .withAppRouter()
            }
            .tabItem { Label("さがす", systemImage: "magnifyingglass") }

            NavigationStack(path: $recommendRouter.path) {
                RecommendView()
                    .withAppRouter()
            }
            .tabItem { Label("おすすめ", systemImage: "books.vertical") }
        }
    }
}
