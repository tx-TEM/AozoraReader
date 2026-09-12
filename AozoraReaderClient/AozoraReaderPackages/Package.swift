// swift-tools-version: 6.0

import PackageDescription

// MARK: Feature

// Feature の追加はこの配列に1行足すだけ。依存は標準セットに統一する
let featureNames: [String] = [
    "Browse",
]

let featureProducts: [Product] = featureNames.map {
    .library(name: "\($0)Feature", targets: ["\($0)Feature"])
}

let featureTargets: [Target] = featureNames.map {
    .target(
        name: "\($0)Feature",
        dependencies: [
            .target(name: "Repository"),
            .target(name: "Response"),
            .target(name: "Routing"),
        ],
        path: "Sources/Features/\($0)Feature",
        sources: ["Sources"]
    )
}

let package = Package(
    name: "AozoraReaderPackages",
    platforms: [
        .iOS(.v18),
    ],
    products: [
        .library(name: "AozoraAPI", targets: ["AozoraAPI"]),
        .library(name: "Repository", targets: ["Repository"]),
        .library(name: "Response", targets: ["Response"]),
        .library(name: "Routing", targets: ["Routing"]),
    ] + featureProducts,
    dependencies: [
        .package(url: "https://github.com/apple/swift-openapi-generator", from: "1.11.1"),
        .package(url: "https://github.com/apple/swift-openapi-runtime", from: "1.11.0"),
        .package(url: "https://github.com/apple/swift-openapi-urlsession", from: "1.2.0"),
    ],
    targets: [
        .target(name: "Response"),
        .target(name: "Routing"),
        .target(
            name: "AozoraAPI",
            dependencies: [
                .product(name: "OpenAPIRuntime", package: "swift-openapi-runtime"),
                .product(name: "OpenAPIURLSession", package: "swift-openapi-urlsession"),
                .target(name: "Response"),
            ],
            plugins: [
                .plugin(name: "OpenAPIGenerator", package: "swift-openapi-generator"),
            ]
        ),
        .target(
            name: "Repository",
            dependencies: [
                .target(name: "AozoraAPI"),
                .target(name: "Response"),
            ]
        ),
        .testTarget(name: "AozoraReaderPackagesTests"),
    ] + featureTargets,
    swiftLanguageModes: [.v6]
)
