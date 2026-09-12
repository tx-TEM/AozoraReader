import Foundation
import SQLite

/// 青空文庫の作品リストから生成した SQLite を読み出すストレージ。
///
/// DB は `scripts/build_db.py` が CSV から生成したもので、
/// books / persons / book_persons の 3 テーブルに正規化されている。
/// 読み取り専用なので書き込み系の API は持たない。
actor BooksStorage {
    /// 一覧 API が一度に返せる最大件数。
    static let maxLimit = 200

    private let db: Connection

    init(path: String) throws {
        db = try Connection(path, readonly: true)
    }

    // MARK: - 作品

    /// 条件に一致する作品を、総件数つきで返す。
    func books(
        title: String?,
        author: String?,
        personId: Int?,
        limit: Int,
        offset: Int
    ) throws -> (total: Int, items: [Components.Schemas.Book]) {
        var conditions: [String] = []
        var bindings: [Binding?] = []

        if let title, !title.isEmpty {
            let pattern = likePattern(title)
            conditions.append("""
                (b.title LIKE ? ESCAPE '\\'
                 OR b.title_kana LIKE ? ESCAPE '\\')
                """)
            bindings.append(contentsOf: [pattern, pattern])
        }

        if let author, !author.isEmpty {
            conditions.append("""
                EXISTS (
                    SELECT 1 FROM book_persons bp
                    JOIN persons p ON p.person_id = bp.person_id
                    WHERE bp.book_id = b.book_id AND p.full_name LIKE ? ESCAPE '\\'
                )
                """)
            bindings.append(likePattern(author))
        }

        if let personId {
            conditions.append("""
                EXISTS (
                    SELECT 1 FROM book_persons bp2
                    WHERE bp2.book_id = b.book_id AND bp2.person_id = ?
                )
                """)
            bindings.append(Int64(personId))
        }

        let whereClause = conditions.isEmpty ? "" : "WHERE " + conditions.joined(separator: " AND ")

        let total = try db.scalar("SELECT count(*) FROM books b \(whereClause)", bindings)
        let total32 = Int(total as? Int64 ?? 0)

        let rows = try db.prepare(
            """
            SELECT \(Self.bookColumns) FROM books b
            \(whereClause)
            ORDER BY b.title_sort_kana, b.book_id
            LIMIT ? OFFSET ?
            """,
            bindings + [Int64(limit), Int64(offset)]
        )

        var books = rows.map(makeBook(from:))
        try attachContributors(to: &books)
        return (total32, books)
    }

    /// 作品を 1 件返す。存在しなければ nil。
    func book(id: Int) throws -> Components.Schemas.Book? {
        let row = try db.prepare(
            "SELECT \(Self.bookColumns) FROM books b WHERE b.book_id = ?",
            [Int64(id)]
        ).makeIterator().next()

        guard let row else { return nil }
        var books = [makeBook(from: row)]
        try attachContributors(to: &books)
        return books[0]
    }

    // MARK: - 人物

    /// 人物を 1 件返す。存在しなければ nil。
    func person(id: Int) throws -> Components.Schemas.Person? {
        let row = try db.prepare(
            """
            SELECT person_id, last_name, first_name, last_name_kana, first_name_kana,
                   last_name_roman, first_name_roman, birth_date, death_date, copyright
            FROM persons WHERE person_id = ?
            """,
            [Int64(id)]
        ).makeIterator().next()

        guard let row else { return nil }
        return Components.Schemas.Person(
            id: int(row[0]),
            lastName: string(row[1]),
            firstName: string(row[2]),
            lastNameKana: optional(row[3]),
            firstNameKana: optional(row[4]),
            lastNameRoman: optional(row[5]),
            firstNameRoman: optional(row[6]),
            birthDate: optional(row[7]),
            deathDate: optional(row[8]),
            copyright: int(row[9]) == 1
        )
    }

    // MARK: - 組み立て

    private static let bookColumns = """
        b.book_id, b.title, b.title_kana, b.subtitle, b.first_appearance, b.ndc,
        b.kana_type, b.copyright, b.release_date, b.card_url, b.text_url, b.html_url
        """

    private func makeBook(from row: [Binding?]) -> Components.Schemas.Book {
        Components.Schemas.Book(
            id: int(row[0]),
            title: string(row[1]),
            titleKana: optional(row[2]),
            subtitle: optional(row[3]),
            firstAppearance: optional(row[4]),
            ndc: optional(row[5]),
            kanaType: optional(row[6]),
            copyright: int(row[7]) == 1,
            releaseDate: optional(row[8]),
            cardUrl: optional(row[9]),
            textUrl: optional(row[10]),
            htmlUrl: optional(row[11]),
            contributors: []
        )
    }

    /// 作品ごとに人物を引くと N+1 になるので、まとめて 1 回で引いて詰め直す。
    private func attachContributors(to books: inout [Components.Schemas.Book]) throws {
        guard !books.isEmpty else { return }

        let ids = books.map { Int64($0.id) as Binding? }
        let placeholders = Array(repeating: "?", count: ids.count).joined(separator: ",")
        let rows = try db.prepare(
            """
            SELECT bp.book_id, p.person_id, p.full_name, bp.role
            FROM book_persons bp
            JOIN persons p ON p.person_id = bp.person_id
            WHERE bp.book_id IN (\(placeholders))
            ORDER BY bp.book_id, bp.role, p.person_id
            """,
            ids
        )

        var byBook: [Int: [Components.Schemas.Contributor]] = [:]
        for row in rows {
            byBook[int(row[0]), default: []].append(
                Components.Schemas.Contributor(
                    personId: int(row[1]),
                    name: string(row[2]),
                    role: string(row[3])
                )
            )
        }

        for index in books.indices {
            books[index].contributors = byBook[books[index].id] ?? []
        }
    }

    // MARK: - 値の取り出し

    private func string(_ value: Binding?) -> String { value as? String ?? "" }

    /// 空文字は JSON に出さないので nil に潰す。
    private func optional(_ value: Binding?) -> String? {
        let text = string(value)
        return text.isEmpty ? nil : text
    }

    private func int(_ value: Binding?) -> Int { Int(value as? Int64 ?? 0) }

    /// LIKE のワイルドカードを打ち消したうえで部分一致パターンにする。
    private func likePattern(_ keyword: String) -> String {
        let escaped = keyword
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "%", with: "\\%")
            .replacingOccurrences(of: "_", with: "\\_")
        return "%\(escaped)%"
    }
}
