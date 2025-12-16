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
        // .package(url: "https://github.com/swiftlang/swift-testing.git", from: "6.2.0"),
        .package(url: "https://github.com/leviouwendijk/plate.git", branch: "master"),
        // .package(url: "https://github.com/leviouwendijk/Structures.git", branch: "master"),
        .package(url: "https://github.com/leviouwendijk/Primitives.git", branch: "master"),
        .package(url: "https://github.com/leviouwendijk/Methods.git", branch: "master"),
    ],
    targets: [
        .target(
            name: "Constructors",
            dependencies: [
                .product(name: "plate", package: "plate"),
                // .product(name: "Structures", package: "Structures"),
                .product(name: "Primitives", package: "Primitives"),
                .product(name: "Methods", package: "Methods"),
            ],
        ),
        .testTarget(
            name: "ConstructorsTests",
            dependencies: [
                "Constructors",
                // .product(name: "Testing", package: "swift-testing"),
            ]
        ),
    ]
)
