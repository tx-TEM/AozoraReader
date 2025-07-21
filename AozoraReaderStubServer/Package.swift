// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AozoraReaderStubServer",
    platforms: [
        .macOS(.v10_15)
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-openapi-generator", from: "1.6.0"),
        .package(url: "https://github.com/apple/swift-openapi-runtime", from: "1.7.0"),
        .package(url: "https://github.com/swift-server/swift-openapi-vapor", from: "1.0.0"),
        .package(url: "https://github.com/vapor/vapor", from: "4.89.0"),
        .package(url: "https://github.com/vapor/fluent", from: "4.0.0"),
        .package(url: "https://github.com/vapor/fluent-sqlite-driver", from: "4.0.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .executableTarget(
            name: "AozoraReaderStubServer",
            dependencies: [
                     .product(name: "OpenAPIRuntime", package: "swift-openapi-runtime"),
                     .product(name: "OpenAPIVapor", package: "swift-openapi-vapor"),
                     .product(name: "Vapor", package: "vapor"),
                     .product(name: "Fluent", package: "fluent"),
                     .product(name: "FluentSQLiteDriver", package: "fluent-sqlite-driver")
                 ],
                 plugins: [
                     .plugin(name: "OpenAPIGenerator", package: "swift-openapi-generator"),
                 ]
        ),
    ]
)
