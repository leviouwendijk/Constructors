import CSS
import Constructors
import DSL
import Foundation
import HTML
import Path
import TestFlows

extension ConstructorsFlowSuite {
    static let artifactTree =
        TestFlow(
            "artifact-tree",
            title:
                "The artifact tree plans paths from templates and derives every href from them",
            tags: [
                "constructors",
                "artifact-tree",
                "linker",
            ]
        ) {
            Step(
                "plan documents, stylesheets, scripts, assets and text"
            ) {
                var tree = ArtifactTree()
                let guide = try SiteRoute(parsingPath: "/guide/setup")
                let wordmark = StructuredContent.AssetKey(rawValue: "images/wordmark")

                try tree.add(.document(HTMLDocument(attributes: .empty, head: [HTML.title("Home")], body: [])), as: .document(.root))
                try tree.add(.document(HTMLDocument(attributes: .empty, head: [HTML.title("Setup")], body: [])), as: .document(guide))
                try tree.add(.stylesheet(CSSStyleSheet(rules: [CSSRule]())), as: .stylesheet(.site))
                try tree.add(.script("console.log(1)"), as: .script(.site))
                try tree.add(.asset(.bytes(Data([1, 2, 3]), extension: "svg")), as: .asset(wordmark))
                try tree.add(.text("User-agent: *\n"), as: .text(StandardPath(rawPath: "robots.txt")))

                try Expect.equal(
                    tree.entries.map { $0.path.rendered(asRootPath: false) },
                    [
                        "index.html",
                        "guide/setup/index.html",
                        "assets/css/site.css",
                        "assets/js/site.js",
                        "assets/images/wordmark.svg",
                        "robots.txt",
                    ],
                    "artifact-tree.paths"
                )
                try Expect.equal(try tree.href(for: .document(.root)), "/", "artifact-tree.href.root")
                try Expect.equal(try tree.href(for: .document(guide)), "/guide/setup/", "artifact-tree.href.document")
                try Expect.equal(try tree.href(for: .stylesheet(.site)), "/assets/css/site.css", "artifact-tree.href.stylesheet")
                try Expect.equal(tree.url(asset: wordmark), "/assets/images/wordmark.svg", "artifact-tree.resolver.asset")
                try Expect.equal(
                    tree.url(page: .init(rawValue: "guide/setup"), anchor: .init(rawValue: "install")),
                    "/guide/setup/#install",
                    "artifact-tree.resolver.page"
                )
                try Expect.equal(try tree.bytes(for: .asset(wordmark)), Data([1, 2, 3]), "artifact-tree.bytes.asset")
                try Expect.equal(
                    String(decoding: try tree.bytes(for: .script(.site)), as: UTF8.self),
                    "console.log(1)",
                    "artifact-tree.bytes.script"
                )
                try Expect.true(tree.pathTree.contains(path: try Expect.notNil(tree.path(for: .stylesheet(.site)), "artifact-tree.stylesheet-path")), "artifact-tree.path-tree")
            }

            Step(
                "reject duplicates, kind mismatches and missing links"
            ) {
                var tree = ArtifactTree()
                try tree.add(.text("a"), as: .text(StandardPath(rawPath: "robots.txt")))

                try Expect.throwsError("artifact-tree.duplicate-key") {
                    try tree.add(.text("b"), as: .text(StandardPath(rawPath: "robots.txt")))
                }
                try Expect.throwsError("artifact-tree.kind-mismatch") {
                    try tree.add(.text("b"), as: .stylesheet(.site))
                }
                try Expect.throwsError("artifact-tree.unresolved-link") {
                    _ = try tree.href(for: .stylesheet(.site))
                }

                var colliding = ArtifactTree(
                    profile: .init(stylesheet: .init(.literal("robots.txt")))
                )
                try colliding.add(.text("a"), as: .text(StandardPath(rawPath: "robots.txt")))
                try Expect.throwsError("artifact-tree.duplicate-path") {
                    try colliding.add(.stylesheet(CSSStyleSheet(rules: [CSSRule]())), as: .stylesheet(.site))
                }
            }

            Step(
                "write a tree's bytes, binary assets included"
            ) {
                let root = FileManager.default.temporaryDirectory
                    .appendingPathComponent("artifact-tree-\(UUID().uuidString)", isDirectory: true)
                defer { try? FileManager.default.removeItem(at: root) }

                var tree = ArtifactTree()
                try tree.add(.stylesheet(CSSStyleSheet(rules: [CSSRule]())), as: .stylesheet(.site))
                try tree.add(.asset(.bytes(Data([0, 255, 7]), extension: "png")), as: .asset(.init(rawValue: "logo")))

                let written = try StaticFileWriter(root: root).write(tree)

                try Expect.equal(
                    written.map { $0.path.replacingOccurrences(of: root.standardizedFileURL.path + "/", with: "") },
                    ["assets/css/site.css", "assets/logo.png"],
                    "artifact-tree.write.destinations"
                )
                try Expect.equal(
                    FileManager.default.contents(atPath: written[1].path),
                    Data([0, 255, 7]),
                    "artifact-tree.write.binary"
                )
            }

            Step(
                "hash asset names on request"
            ) {
                var tree = ArtifactTree(profile: .init(hashesAssetNames: true))
                let path = try tree.add(
                    .asset(.bytes(Data("logo".utf8), extension: "png")),
                    as: .asset(.init(rawValue: "logo"))
                ).rendered(asRootPath: false)

                try Expect.true(path.hasPrefix("assets/logo."), "artifact-tree.hash.prefix")
                try Expect.true(path.hasSuffix(".png"), "artifact-tree.hash.extension")
                try Expect.equal(path.count, "assets/logo.12345678.png".count, "artifact-tree.hash.length")
            }
        }
}
