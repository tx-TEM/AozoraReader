# メタデータ DB

[CSV](data-source.md) を正規化した SQLite。サーバーが読み取り専用で開く。

| 項目 | 値 |
|---|---|
| 生成スクリプト | [`scripts/build_db.py`](../../AozoraReaderMockServer/scripts/build_db.py) |
| ファイル | `AozoraReaderMockServer/Sources/SQLite/aozora_database.sqlite3`（約 9.0 MB） |
| 読み出し | [`BooksStorage`](../../AozoraReaderMockServer/Sources/Database/BooksStorage.swift) — `actor`、`Connection(path, readonly: true)` |
| 同梱 | SwiftPM の `resources: [.copy("SQLite/aozora_database.sqlite3")]` で実行ファイルのバンドルに入る |

## 生成

```bash
curl -O https://www.aozora.gr.jp/index_pages/list_person_all_extended_utf8.zip
unzip list_person_all_extended_utf8.zip
python3 scripts/build_db.py list_person_all_extended_utf8.csv Sources/SQLite/aozora_database.sqlite3
```

出力例:

```
books:        17717
persons:      1332
book_persons: 19375
wrote ... (9.0 MB)
```

`build_db.py` の動作:

1. 出力先が既にあれば**ファイルごと削除**してから作り直す
2. `DROP TABLE` → `CREATE TABLE` でスキーマを張る
3. CSV を 1 行ずつ読み、`books` / `persons` は `setdefault` で重複を除き、`book_persons` は `set` に溜める
4. `executemany` で一括 INSERT → `VACUUM`

作品ID・人物IDが数値でない行はスキップされる（現在のデータでは 0 件）。

> 再生成のたびに中身が全部入れ替わる。**このファイルに運用データを置くことはできない。**

## スキーマ

### books（17,717 行）

| 列 | 型 | 内容 |
|---|---|---|
| `book_id` | INTEGER PK | 作品ID |
| `title` | TEXT | 作品名 |
| `title_kana` | TEXT | 作品名読み |
| `title_sort_kana` | TEXT | ソート用読み |
| `subtitle` / `subtitle_kana` | TEXT | 副題・読み |
| `original_title` | TEXT | 原題 |
| `first_appearance` | TEXT | 初出 |
| `ndc` | TEXT | 分類番号 |
| `kana_type` | TEXT | 文字遣い種別 |
| `copyright` | INTEGER | 作品著作権フラグ（1 / 0） |
| `release_date` / `last_modified` | TEXT | 公開日・最終更新日 |
| `card_url` / `text_url` / `text_encoding` / `html_url` | TEXT | [本文ファイルの在り処](data-source.md#本文ファイルの-url) |

全列 `NOT NULL DEFAULT ''`。値が無い場合は NULL ではなく空文字。

### persons（1,332 行）

| 列 | 内容 |
|---|---|
| `person_id` | INTEGER PK |
| `last_name` / `first_name` | 姓・名 |
| `last_name_kana` / `first_name_kana` | 読み |
| `last_name_sort_kana` / `first_name_sort_kana` | ソート用読み |
| `last_name_roman` / `first_name_roman` | ローマ字 |
| `birth_date` / `death_date` | 生没年月日 |
| `copyright` | 人物著作権フラグ |
| `full_name` | 姓と名を**半角スペースで連結**したもの |

`full_name` は CSV に無く、`build_db.py` が生成している非正規化列。検索で使う。

### book_persons（19,375 行）

| 列 | 内容 |
|---|---|
| `book_id` | `books` への参照 |
| `person_id` | `persons` への参照 |
| `role` | 役割フラグ |

主キーは `(book_id, person_id, role)`。同一人物が 1 作品で複数の役割を持てる。

`role` の分布:

| role | 件数 |
|---|---|
| 著者 | 18,181 |
| 翻訳者 | 1,144 |
| 校訂者 | 28 |
| 編者 | 16 |
| その他 | 6 |

### 索引

```sql
CREATE INDEX idx_books_title         ON books(title);
CREATE INDEX idx_books_sort          ON books(title_sort_kana);
CREATE INDEX idx_book_persons_person ON book_persons(person_id);
CREATE INDEX idx_persons_full_name   ON persons(full_name);
```

## 値の実情

API を使う側が把握しておくべき、データの形と欠損。

### 値の書式

| 列 | 形 | 例 |
|---|---|---|
| `release_date` / `last_modified` | ISO 形式 | `2000-12-04` |
| `ndc` | **`NDC ` の接頭辞つき**。児童書は `K` が入る | `NDC 913`, `NDC K933` |
| `birth_date` / `death_date` | ISO 形式。不明な場合は空 | `1909-06-19` |
| `text_encoding` | 文字列 | `ShiftJIS`, `UTF-8` |

### 欠損・偏り

| 列 | 状況 |
|---|---|
| `ndc` | 630 行が空 |
| `text_url` | 154 行が空 |
| `html_url` | 93 行が空 |
| `text_encoding` | `ShiftJIS` 17,558 / `UTF-8` 5 / 空 154 |
| `copyright`（作品） | 0（切れている）17,236 / 1（残っている）481 |

`text_url` / `html_url` のうち約 200 行は `www.aozora.gr.jp` 以外のホストを指している
（個人サイト、`mega.nz`、`googledrive.com` など）。本文取得を実装する段階で扱いを決める必要がある。

## 読み出し

`BooksStorage` が 3 つのメソッドを持つ。SQL は素の文字列で書き、値はすべてプレースホルダでバインドしている。

| メソッド | 対応するエンドポイント |
|---|---|
| `books(title:author:personId:limit:offset:)` | `GET /books` |
| `book(id:)` | `GET /books/{bookId}` |
| `person(id:)` | `GET /persons/{personId}` |

### 検索条件の組み立て

絞り込みは 3 つあり、渡されたものが AND で連結される。

`title` は作品名と作品名読みの OR。

```sql
(b.title LIKE ? ESCAPE '\' OR b.title_kana LIKE ? ESCAPE '\')
```

`author` は人物名。

```sql
EXISTS (SELECT 1 FROM book_persons bp JOIN persons p ON p.person_id = bp.person_id
        WHERE bp.book_id = b.book_id AND p.full_name LIKE ? ESCAPE '\')
```

`personId` は `book_persons` の EXISTS で絞る。人物名の文字列ではなく ID 指定。

`likePattern(_:)` が `\` `%` `_` をエスケープしてから `%...%` で囲むので、
ユーザーが `%` を入れても全件一致にはならない（実測で 0 件）。

**本文は検索対象ではない。** 作品名・作品名読み・人物名のみ。

実測値:

| 条件 | 件数 |
|---|---|
| なし | 17,717 |
| `title=走れ` | 1 |
| `author=太宰` | 274 |
| `title=手紙&author=堀` | 7 |

### 並び順

`ORDER BY b.title_sort_kana, b.book_id` 固定。指定する手段は無い。

### 件数の取得

同じ WHERE 句で `SELECT count(*)` を別に実行して `total` を出している。

### contributors の取得

作品ごとに人物を引くと N+1 になるため、`attachContributors(to:)` が
対象作品の ID をまとめて `IN (...)` で 1 回引き、作品に詰め直している。

並びは `ORDER BY bp.book_id, bp.role, p.person_id`。
`role` は**文字列順**なので、意味的な順序にはならない（「翻訳者」が「著者」より先に来る）。

```
book_id 193「尼」の contributors
  翻訳者 森 鴎外 (129)
  翻訳者 森 林太郎 (315)
  著者  ウィード グスターフ (17)
```

### 空文字の扱い

`optional(_:)` が空文字を `nil` に潰すため、値が無い列は **JSON のキーごと出ない**。
副題のない作品のレスポンスに `subtitle` キーは存在しない。受け側は
`openapi.yaml` の `required` 以外を省略可として扱う必要がある。

### API に出していない列

`title_sort_kana`、`subtitle_kana`、`original_title`、`text_encoding`、`last_modified` は
`BooksStorage` の `bookColumns` に入っておらず、API からは見えない。
`text_encoding` は本文を取得する段階で必要になる。
