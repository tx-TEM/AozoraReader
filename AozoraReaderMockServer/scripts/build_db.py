#!/usr/bin/env python3
"""青空文庫の公開作品リスト CSV から、モックサーバー用の SQLite DB を生成する。

入力は青空文庫が配布している拡張版の CSV (UTF-8)。
    https://www.aozora.gr.jp/index_pages/person_all.html
    list_person_all_extended_utf8.csv

CSV は「作品 × 人物」の 1 行が 1 レコードなので、
books / persons / book_persons の 3 テーブルに正規化して投入する。
あわせて、分類番号からカテゴリーを割り出して categories / book_categories に入れる。

usage:
    python3 scripts/build_db.py <input.csv> <output.sqlite3>
"""

import csv
import sqlite3
import sys
from pathlib import Path

SCHEMA = """
DROP TABLE IF EXISTS book_categories;
DROP TABLE IF EXISTS categories;
DROP TABLE IF EXISTS book_persons;
DROP TABLE IF EXISTS books;
DROP TABLE IF EXISTS persons;

CREATE TABLE books (
    book_id          INTEGER PRIMARY KEY,
    title            TEXT NOT NULL,
    title_kana       TEXT NOT NULL DEFAULT '',
    title_sort_kana  TEXT NOT NULL DEFAULT '',
    subtitle         TEXT NOT NULL DEFAULT '',
    subtitle_kana    TEXT NOT NULL DEFAULT '',
    original_title   TEXT NOT NULL DEFAULT '',
    first_appearance TEXT NOT NULL DEFAULT '',
    ndc              TEXT NOT NULL DEFAULT '',
    kana_type        TEXT NOT NULL DEFAULT '',
    copyright        INTEGER NOT NULL DEFAULT 0,
    release_date     TEXT NOT NULL DEFAULT '',
    last_modified    TEXT NOT NULL DEFAULT '',
    card_url         TEXT NOT NULL DEFAULT '',
    text_url         TEXT NOT NULL DEFAULT '',
    text_encoding    TEXT NOT NULL DEFAULT '',
    html_url         TEXT NOT NULL DEFAULT ''
);

CREATE TABLE persons (
    person_id            INTEGER PRIMARY KEY,
    last_name            TEXT NOT NULL DEFAULT '',
    first_name           TEXT NOT NULL DEFAULT '',
    last_name_kana       TEXT NOT NULL DEFAULT '',
    first_name_kana      TEXT NOT NULL DEFAULT '',
    last_name_sort_kana  TEXT NOT NULL DEFAULT '',
    first_name_sort_kana TEXT NOT NULL DEFAULT '',
    last_name_roman      TEXT NOT NULL DEFAULT '',
    first_name_roman     TEXT NOT NULL DEFAULT '',
    birth_date           TEXT NOT NULL DEFAULT '',
    death_date           TEXT NOT NULL DEFAULT '',
    copyright            INTEGER NOT NULL DEFAULT 0,
    full_name            TEXT NOT NULL DEFAULT ''
);

CREATE TABLE book_persons (
    book_id   INTEGER NOT NULL REFERENCES books(book_id),
    person_id INTEGER NOT NULL REFERENCES persons(person_id),
    role      TEXT NOT NULL DEFAULT '',
    PRIMARY KEY (book_id, person_id, role)
);

CREATE TABLE categories (
    category_id TEXT PRIMARY KEY,
    name        TEXT NOT NULL
);

CREATE TABLE book_categories (
    book_id     INTEGER NOT NULL REFERENCES books(book_id),
    category_id TEXT NOT NULL REFERENCES categories(category_id),
    PRIMARY KEY (book_id, category_id)
);

CREATE INDEX idx_books_title ON books(title);
CREATE INDEX idx_books_sort ON books(title_sort_kana);
CREATE INDEX idx_book_persons_person ON book_persons(person_id);
CREATE INDEX idx_persons_full_name ON persons(full_name);
CREATE INDEX idx_book_categories_category ON book_categories(category_id);
"""

# カテゴリーは NDC の類。ID は類の番号で、分類番号の無い作品は other に入れる。
# 文字の順で数字が英字より前に来るので、ID で並べると other が最後になる。
OTHER_CATEGORY = "other"
CATEGORIES = [
    ("0", "総記"),
    ("1", "哲学"),
    ("2", "歴史"),
    ("3", "社会科学"),
    ("4", "自然科学"),
    ("5", "技術．工学"),
    ("6", "産業"),
    ("7", "芸術．美術"),
    ("8", "言語"),
    ("9", "文学"),
    (OTHER_CATEGORY, "その他"),
]

# 青空文庫の ID は "059898" のようにゼロ埋めされた文字列。
# URL は CSV の値をそのまま持つので、ID 自体は整数で扱う。
def to_id(value):
    value = (value or "").strip()
    return int(value) if value.isdigit() else None


def to_flag(value):
    # 著作権フラグは "あり" / "なし"
    return 1 if (value or "").strip() == "あり" else 0


def to_category_ids(ndc):
    """分類番号（"NDC K913 914" など）から、当てはまるカテゴリーの ID を返す。

    児童書の印の K は無視する。番号が 1 つも無ければ other。
    """
    codes = (ndc or "").replace("NDC", "").split()
    ids = {code.lstrip("K")[:1] for code in codes if code.lstrip("K")[:1].isdigit()}
    return ids or {OTHER_CATEGORY}


def main(csv_path: Path, db_path: Path) -> None:
    db_path.parent.mkdir(parents=True, exist_ok=True)
    if db_path.exists():
        db_path.unlink()

    conn = sqlite3.connect(db_path)
    conn.executescript(SCHEMA)

    books = {}
    persons = {}
    links = set()
    skipped = 0

    # BOM 付きで配布されているので utf-8-sig で開く
    with csv_path.open(encoding="utf-8-sig", newline="") as f:
        for row in csv.DictReader(f):
            book_id = to_id(row["作品ID"])
            person_id = to_id(row["人物ID"])
            if book_id is None or person_id is None:
                skipped += 1
                continue

            books.setdefault(book_id, (
                book_id,
                row["作品名"],
                row["作品名読み"],
                row["ソート用読み"],
                row["副題"],
                row["副題読み"],
                row["原題"],
                row["初出"],
                row["分類番号"],
                row["文字遣い種別"],
                to_flag(row["作品著作権フラグ"]),
                row["公開日"],
                row["最終更新日"],
                row["図書カードURL"],
                row["テキストファイルURL"],
                row["テキストファイル符号化方式"],
                row["XHTML/HTMLファイルURL"],
            ))

            persons.setdefault(person_id, (
                person_id,
                row["姓"],
                row["名"],
                row["姓読み"],
                row["名読み"],
                row["姓読みソート用"],
                row["名読みソート用"],
                row["姓ローマ字"],
                row["名ローマ字"],
                row["生年月日"],
                row["没年月日"],
                to_flag(row["人物著作権フラグ"]),
                " ".join(x for x in (row["姓"], row["名"]) if x),
            ))

            links.add((book_id, person_id, row["役割フラグ"]))

    conn.executemany(
        "INSERT INTO books VALUES (%s)" % ",".join("?" * 17), books.values()
    )
    conn.executemany(
        "INSERT INTO persons VALUES (%s)" % ",".join("?" * 13), persons.values()
    )
    conn.executemany("INSERT INTO book_persons VALUES (?,?,?)", sorted(links))

    book_categories = sorted(
        (book_id, category_id)
        for book_id, book in books.items()
        for category_id in to_category_ids(book[8])
    )
    conn.executemany("INSERT INTO categories VALUES (?,?)", CATEGORIES)
    conn.executemany("INSERT INTO book_categories VALUES (?,?)", book_categories)
    conn.commit()
    conn.execute("VACUUM")
    conn.close()

    print(f"books:        {len(books)}")
    print(f"persons:      {len(persons)}")
    print(f"book_persons: {len(links)}")
    print(f"book_categories: {len(book_categories)}")
    if skipped:
        print(f"skipped rows: {skipped}")
    print(f"wrote {db_path} ({db_path.stat().st_size / 1024 / 1024:.1f} MB)")


if __name__ == "__main__":
    if len(sys.argv) != 3:
        sys.exit(__doc__)
    main(Path(sys.argv[1]).expanduser(), Path(sys.argv[2]).expanduser())
