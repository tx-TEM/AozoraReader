import Foundation
import Vapor
import OpenAPIRuntime
import OpenAPIVapor
import SQLite

struct AozoraServiceAPIHandler: APIProtocol {
    let storage: BooksStorage

    func getBooks(
        _ input: Operations.GetBooks.Input
    ) async throws -> Operations.GetBooks.Output {
        let limit = min(max(input.query.limit ?? 50, 1), BooksStorage.maxLimit)
        let offset = max(input.query.offset ?? 0, 0)

        let page = try await storage.books(
            title: input.query.title,
            author: input.query.author,
            personId: input.query.personId,
            limit: limit,
            offset: offset
        )

        return .ok(.init(body: .json(.init(
            total: page.total,
            limit: limit,
            offset: offset,
            items: page.items
        ))))
    }

    func getRecommendations(
        _ input: Operations.GetRecommendations.Input
    ) async throws -> Operations.GetRecommendations.Output {
        let sections = try await storage.recommendations()
        return .ok(.init(body: .json(.init(sections: sections))))
    }

    func getBook(
        _ input: Operations.GetBook.Input
    ) async throws -> Operations.GetBook.Output {
        guard let book = try await storage.book(id: input.path.bookId) else {
            return .notFound(.init())
        }
        return .ok(.init(body: .json(book)))
    }

    func getPerson(
        _ input: Operations.GetPerson.Input
    ) async throws -> Operations.GetPerson.Output {
        guard let person = try await storage.person(id: input.path.personId) else {
            return .notFound(.init())
        }
        return .ok(.init(body: .json(person)))
    }

    func getGreeting(
        _ input: Operations.GetGreeting.Input
    ) async throws -> Operations.GetGreeting.Output {
        let name = input.query.name ?? "Stranger"
        let greeting = Components.Schemas.Greeting(message: "Hello, \(name)!")
        return .ok(.init(body: .json(greeting)))
    }
}

guard let databasePath = Bundle.module.path(forResource: "aozora_database", ofType: "sqlite3") else {
    fatalError("aozora_database.sqlite3 が見つかりません。scripts/build_db.py で生成してください。")
}

// openapi.yaml の servers 先頭に書いたローカル用 URL。
// 生成される型名は Server1 固定（generator が index で名前を付けるため）なので、
// ここで呼び名を与えておく。
let localServerURL = try Servers.Server1.url()

let app = try await Vapor.Application.make()
let transport = VaporTransport(routesBuilder: app)
let handler = AozoraServiceAPIHandler(storage: try BooksStorage(path: databasePath))
try handler.registerHandlers(on: transport, serverURL: localServerURL)
try await app.execute()
