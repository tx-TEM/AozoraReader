/// 何をどの対象で絞り込むか。一覧はこの値ごとに取り直す。
struct SearchQuery: Equatable {
    var keyword: String
    var target: FilterTarget

    var title: String? {
        target == .title ? filter : nil
    }

    var author: String? {
        target == .author ? filter : nil
    }

    private var filter: String? {
        keyword.isEmpty ? nil : keyword
    }
}
