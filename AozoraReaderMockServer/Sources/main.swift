import Foundation
import Vapor
import OpenAPIRuntime
import OpenAPIVapor
import SQLite

struct GreetingServiceAPIImpl: APIProtocol {
    func getGreeting(
        _ input: Operations.GetGreeting.Input
    ) async throws -> Operations.GetGreeting.Output {
        let name = input.query.name ?? "Stranger"
        let greeting = Components.Schemas.Greeting(message: "Hello, \(name)!")
        return .ok(.init(body: .json(greeting)))
    }
}

let app = try await Vapor.Application.make()
let transport = VaporTransport(routesBuilder: app)
let handler = GreetingServiceAPIImpl()
try handler.registerHandlers(on: transport, serverURL: Servers.Server1.url())
try await app.execute()
