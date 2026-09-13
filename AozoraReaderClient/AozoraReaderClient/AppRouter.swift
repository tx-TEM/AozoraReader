import DetailFeature
import ReaderFeature
import Routing
import SwiftUI

extension View {
    /// 遷移先を実際の画面に解決する。
    func withAppRouter() -> some View {
        navigationDestination(for: Destination.self) { destination in
            switch destination {
            case .book(let id):
                DetailView(bookId: id)
            case .reader(let url):
                ReaderView(url: url)
            }
        }
    }
}
