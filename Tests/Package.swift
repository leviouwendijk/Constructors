// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ConstructorsTests",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "constructorstest",
            targets: [
                "ConstructorsTestFlows",
            ]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/swift-lco/Primitives.git", branch: "master"),
        .package(url: "https://github.com/swift-tooling/TestFlows.git", branch: "master"),

        .package(url: "https://github.com/swift-dsl/HTML.git", branch: "master"),
        .package(url: "https://github.com/swift-dsl/CSS.git", branch: "master"),
        .package(url: "https://github.com/swift-dsl/JS.git", branch: "master"),
        .package(url: "https://github.com/swift-lco/Path.git", branch: "master"),
        .package(url: "https://github.com/swift-dsl/DSL.git", branch: "master"),
        .package(path: ".."),
    ],
    targets: [
        .executableTarget(
            name: "ConstructorsTestFlows",
            dependencies: [
                .product(name: "Constructors", package: "Constructors"),
                .product(name: "DSL", package: "DSL"),
                .product(
                    name: "Primitives",
                    package: "Primitives"
                ),
                .product(
                    name: "Path",
                    package: "Path"
                ),
                .product(
                    name: "CSS",
                    package: "CSS"
                ),
                .product(
                    name: "HTML",
                    package: "HTML"
                ),
                .product(
                    name: "JS",
                    package: "JS"
                ),
                .product(
                    name: "TestFlows",
                    package: "TestFlows"
                ),
            ]
        ),
    ]
)
