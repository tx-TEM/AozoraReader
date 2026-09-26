import Observation

/// 遷移の状態。
@MainActor
@Observable
public final class Router {
    public var path: [Destination] = []

    public init() {}

    public func popToRoot() {
        path.removeAll()
    }
}
