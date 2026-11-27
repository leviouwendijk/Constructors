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
        .package(url: "https://github.com/swift-lco/Primitives.git", branch: "master"),
        // .package(url: "https://github.com/swift-lco/Methods.git", branch: "master"),
        // .package(url: "https://github.com/swift-lco/Milieu.git", branch: "master"),
        .package(url: "https://github.com/swift-dsl/DSL.git", branch: "master"),

        .package(url: "https://github.com/swift-dsl/HTML.git", branch: "master"),
        .package(url: "https://github.com/swift-dsl/CSS.git", branch: "master"),
        .package(url: "https://github.com/swift-dsl/JS.git", branch: "master"),

        .package(url: "https://github.com/swift-lco/Milieu.git", branch: "master"),
        .package(url: "https://github.com/swift-lco/Writers.git", branch: "master"),
        .package(url: "https://github.com/swift-lco/Readers.git", branch: "master"),
        .package(url: "https://github.com/swift-lco/Version.git", branch: "master"),
        .package(url: "https://github.com/swift-lco/Path.git", branch: "master"),
        .package(url: "https://github.com/swift-webc/ProtocolComponents.git", branch: "master"),

        .package(url: "https://github.com/swift-lco/Partition.git", branch: "master"),
    ],
    targets: [
        .target(
            name: "Constructors",
            dependencies: [
                .product(name: "Primitives", package: "Primitives"),
                // .product(name: "Methods", package: "Methods"),
                // .product(name: "Milieu", package: "Milieu"),
                .product(name: "DSL", package: "DSL"),

                .product(name: "HTML", package: "HTML"),
                .product(name: "CSS", package: "CSS"),
                .product(name: "JS", package: "JS"),

                .product(name: "Milieu", package: "Milieu"),
                .product(name: "Writers", package: "Writers"),
                .product(name: "Readers", package: "Readers"),
                .product(name: "Version", package: "Version"),
                .product(name: "Path", package: "Path"),
                .product(name: "PathWeb", package: "Path"),
                .product(name: "ProtocolComponents", package: "ProtocolComponents"),

                .product(name: "PartitionFrame", package: "Partition"),
            ],
        ),
    ]
)
