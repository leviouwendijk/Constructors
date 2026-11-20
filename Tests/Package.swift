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
        .package(url: "https://github.com/leviouwendijk/Primitives.git", branch: "master"),
        .package(url: "https://github.com/leviouwendijk/TestFlows.git", branch: "master"),

        .package(url: "https://github.com/leviouwendijk/HTML.git", branch: "master"),
        .package(url: "https://github.com/leviouwendijk/CSS.git", branch: "master"),
        .package(url: "https://github.com/leviouwendijk/JS.git", branch: "master"),
        .package(url: "https://github.com/leviouwendijk/Path.git", branch: "master"),
        .package(path: ".."),
    ],
    targets: [
        .executableTarget(
            name: "ConstructorsTestFlows",
            dependencies: [
                .product(name: "Constructors", package: "Constructors"),
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
