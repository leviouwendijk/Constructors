// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Constructors",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "Constructors",
            targets: ["Constructors"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-testing.git", from: "6.2.0")
    ],
    targets: [
        .target(
            name: "Constructors"
        ),
        .testTarget(
            name: "ConstructorsTests",
            dependencies: [
                "Constructors",
                .product(name: "Testing", package: "swift-testing"),
            ]
        ),
    ]
)
