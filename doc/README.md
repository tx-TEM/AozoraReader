# AozoraReader 設計ドキュメント

## スコープ

現在まとめてあるのは **青空文庫の作品リスト CSV を SQLite にして、API として配るところまで**。
すでに実装が動いている範囲のみを記述している。

| ドキュメント | 内容 |
|---|---|
| [データソース](technical/data-source.md) | 青空文庫が配布している CSV の素性 |
| [メタデータ DB](technical/metadata-db.md) | CSV → SQLite の変換、スキーマ、データの実情 |

API の仕様は [`Sources/openapi.yaml`](../AozoraReaderMockServer/Sources/openapi.yaml) が正。
ここには書き写さない。

画面は [タブ画面](screen/tab.md) から。

```
CSV (青空文庫)  ──build_db.py──▶  SQLite  ──BooksStorage──▶  Vapor + OpenAPI  ──▶  JSON
```

## 進め方

仕様を先に固めきらない。決まっていないことは各ドキュメントの「未定」に残し、
開発しながら詰めていく。

## まだ決めていないこと

本文（作品そのもの）の取得方法、リーダーの実装、画面構成は**未着手**。

## サーバーのビルドと起動

このマシンは `xcode-select -p` が CommandLineTools を指しているため、`DEVELOPER_DIR` の指定が必要。

```bash
cd AozoraReaderMockServer
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer .build/debug/AozoraReaderMockServer
```

`http://localhost:8080/api` で待ち受ける。
DB は `Bundle.module` から探すため、`swift build` でリソースがコピーされている必要がある
（見つからないと `fatalError` で落ちる）。
