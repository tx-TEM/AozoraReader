import Foundation

public enum Destination: Hashable {
    case book(id: Int)
    case reader(url: URL)
}
