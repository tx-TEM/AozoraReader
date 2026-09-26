# AozoraReader 設計ドキュメント

## スコープ

すでに実装が動いている範囲のみを記述している。

| ドキュメント | 内容 |
|---|---|
| [データソース](technical/data-source.md) | 青空文庫が配布している CSV の素性 |
| [メタデータ DB](technical/metadata-db.md) | CSV → SQLite の変換、スキーマ、データの実情 |
| [カテゴリー](technical/category.md) | 分類番号から組み立てる作品の大きな分け方 |
| [ジャンル](technical/genre.md) | カテゴリーの中の分け方 |
| [サブジャンル](technical/subgenre.md) | ジャンルの中の分け方 |

API の仕様は [`Sources/openapi.yaml`](../AozoraReaderMockServer/Sources/openapi.yaml) が正。
ここには書き写さない。

画面は [タブ画面](screen/tab.md) から。

```
CSV (青空文庫)  ──build_db.py──▶  SQLite  ──BooksStorage──▶  Vapor + OpenAPI  ──▶  JSON
```

## 進め方

仕様を先に固めきらない。決まっていないことは各ドキュメントの「未定」に残し、
開発しながら詰めていく。

## サーバーのビルドと起動

以下はリポジトリのルートで叩く。

```bash
swift run --package-path AozoraReaderMockServer
```

`http://localhost:8080/api` で待ち受ける。
DB は `Bundle.module` から探すため、ビルドでリソースがコピーされている必要がある
（見つからないと `fatalError` で落ちる）。
