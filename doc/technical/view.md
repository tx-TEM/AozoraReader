# 画面の View の書き方

画面のファイルを開けば、その画面に何が並んでいて、どこへ遷移するかが分かるようにする。

## 画面の View の中に書く

画面の部品は、画面の View の computed property やメソッドとして書く。
別の型・別のファイルには分けない。

1 ファイルが長くなるときは、部品のまとまりごとに `extension` で切り、`// MARK: -` で名前を付ける。
`body` と、その直下に並ぶものは本体に置く。

```swift
public struct DetailView: View {
    public var body: some View { ... }
    private var content: some View { ... }
}

// MARK: - 書誌

extension DetailView {
    private func bibliographySection(of book: BookResponse) -> some View { ... }
}
```

## 遷移は画面の View に置く

`NavigationLink` は画面の View に書く。部品の中に置かない。

遷移先の画面への解決はアプリ側（`withAppRouter()`）が持つ。
画面は `Destination` の値を渡すだけで、遷移先の画面の型を知らない。

## 子の View に分けてよいもの

次のどれかに当てはまるときだけ、別の型にする。

- **複数の画面で使う。** `UIComponents` に置く
- **自分の状態を持つ。** `SearchBar`、`WebView`、`ErrorView` など
- **再描画を絞りたい。** `@Observable` の値を読む範囲を子に閉じ込めると、
  その値が変わっても親は描き直されない

再描画のための切り出しは先回りでしない。重いと感じたら、`Self._printChanges()` や
Instruments で何度描き直しているかを測り、原因の箇所だけを切り出す。

View でない型（色の表など）は、その画面でしか使わなければ画面のファイルに `private` で置く。
