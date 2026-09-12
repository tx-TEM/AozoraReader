# データソース

作品のメタデータは、青空文庫が配布している「公開中 作品別 作家別一覧」の拡張版 CSV を使う。

| 項目 | 値 |
|---|---|
| 配布ページ | https://www.aozora.gr.jp/index_pages/person_all.html |
| ファイル | `list_person_all_extended_utf8.zip`（約 2.0 MB） |
| 中身 | `list_person_all_extended_utf8.csv`（UTF-8、**BOM 付き**） |
| Shift_JIS 版 | `list_person_all_extended.zip`（約 1.9 MB）。使っていない |

BOM 付きで配布されているため、読むときは `utf-8-sig` 相当の扱いが必要
（[`build_db.py`](../../AozoraReaderMockServer/scripts/build_db.py) は `encoding="utf-8-sig"` で開いている）。

## CSV の粒度

**1 行 = 作品 × 人物。** 同じ作品が、関わった人物のぶん繰り返し現れる。

たとえば翻訳作品は「著者の行」と「翻訳者の行」で 2 行になり、作品側の列（作品名、公開日、URL など）は
どちらの行にも同じ値が入っている。このため、そのままテーブルに入れると作品が重複する。

正規化の方法は [メタデータ DB](metadata-db.md)。

## 主な列

| 分類 | 列 |
|---|---|
| 作品 | 作品ID、作品名、作品名読み、ソート用読み、副題、副題読み、原題、初出、分類番号、文字遣い種別、作品著作権フラグ、公開日、最終更新日 |
| ファイル | 図書カードURL、テキストファイルURL、テキストファイル符号化方式、XHTML/HTMLファイルURL |
| 人物 | 人物ID、姓、名、姓読み、名読み、姓読みソート用、名読みソート用、姓ローマ字、名ローマ字、生年月日、没年月日、人物著作権フラグ |
| 関係 | 役割フラグ |

著作権フラグは `あり` / `なし` の文字列。`build_db.py` が 1 / 0 に変換している。

## 本文ファイルの URL

CSV が本文ファイルの実体 URL を持っている。**図書カードをスクレイピングする必要はない。**

```
作品ID              = 1567（走れメロス）
図書カードURL        = https://www.aozora.gr.jp/cards/000035/card1567.html
テキストファイルURL  = https://www.aozora.gr.jp/cards/000035/files/1567_ruby_4948.zip
XHTML/HTMLファイルURL = https://www.aozora.gr.jp/cards/000035/files/1567_14913.html
```

ファイル名のサフィックス（`_4948`, `_14913`）は**作品が修正されると変わる**ため、
作品 ID から URL を組み立てることはできない。CSV の値をそのまま保存して使う。

URL は DB に保存して API で配っているが、**本文を取得する処理は未実装**。
取得方法は未決。
