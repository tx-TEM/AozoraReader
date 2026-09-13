/// 何で絞り込むか。
enum FilterTarget: CaseIterable {
    case title
    case author

    var name: String {
        switch self {
        case .title: "作品名"
        case .author: "作者"
        }
    }

    var placeholder: String {
        "\(name)で絞り込む"
    }
}
