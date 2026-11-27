import CSS
import Constructors
import DSL
import Foundation
import HTML
import TestFlows

private enum FixtureHome: Site.Declaring {
    static let host = "fixture.example"

    static let home = Site.Page(FixtureHome.self, path: [], title: "Fixture")

    enum Offer {
        static let index = Site.Page(FixtureHome.self, path: ["offer"], title: "Offer", summary: "What we offer")
        static let consult = Site.Page(FixtureHome.self, path: ["offer", "consult"], title: "Consult")
    }

    static var pages: [Site.Page] {
        [home, Offer.index, Offer.consult]
    }
}

private enum FixtureDocs: Site.Declaring {
    static let host = "docs.fixture.example"

    static let home = Site.Page(FixtureDocs.self, path: [], title: "Docs")
    static let basics = Site.Page(FixtureDocs.self, path: ["basics"], title: "Basics", summary: "Start here")

    static var pages: [Site.Page] {
        [home, basics]
    }
}

private enum FixtureOrphan: Site.Declaring {
    static let host = "orphan.example"
    static var pages: [Site.Page] {
        [
            Site.Page(FixtureOrphan.self, path: [], title: "Root"),
            Site.Page(FixtureOrphan.self, path: ["a", "b"], title: "Orphan"),
        ]
    }
}

extension ConstructorsFlowSuite {
    static let siteDeclaration =
        TestFlow(
            "site-declaration",
            title:
                "Declared sites form page trees and resolve typed links within and across sites",
            tags: [
                "constructors",
                "site",
                "declaration",
            ]
        ) {
            Step(
                "pages nest by path"
            ) {
                let tree = try FixtureHome.pageTree()

                try Expect.equal(tree.identifier.rawValue, "index", "site.tree.root")
                try Expect.equal(tree.children.map(\.identifier.rawValue), ["offer"], "site.tree.children")
                try Expect.equal(tree.children.first?.children.map(\.identifier.rawValue), ["offer.consult"], "site.tree.grandchildren")
                try Expect.equal(FixtureHome.Offer.consult.href, "/offer/consult/", "site.page.href")
                try Expect.throwsError("site.tree.orphan") {
                    _ = try FixtureOrphan.pageTree()
                }
            }

            Step(
                "links resolve within a site and across sites"
            ) {
                let directory = Site.Directory([FixtureHome.self, FixtureDocs.self])

                try Expect.equal(
                    try directory.href(for: FixtureHome.Offer.consult, from: FixtureHome.host),
                    "/offer/consult/",
                    "site.link.same-site"
                )
                try Expect.equal(
                    try directory.href(for: FixtureDocs.basics, from: FixtureHome.host),
                    "https://docs.fixture.example/basics/",
                    "site.link.cross-site"
                )
                try Expect.equal(
                    directory.page(FixtureDocs.basics.pageKey)?.summary,
                    "Start here",
                    "site.link.hover-card-metadata"
                )

                let prose = StructuredContent.prose(
                    "Book a \(link: "consult", to: FixtureHome.Offer.consult) or read \(link: "the basics", to: FixtureDocs.basics)."
                )
                let resolver = directory.resolver(from: FixtureHome.host)

                guard case .paragraph(let inlines) = prose,
                      case .link(let first, _) = inlines[1],
                      case .link(let second, _) = inlines[3]
                else {
                    throw TestFlowAssertionFailure(label: "site.link.prose", message: "expected two links")
                }

                try Expect.equal(resolver.url(first), "/offer/consult/", "site.link.prose.same-site")
                try Expect.equal(resolver.url(second), "https://docs.fixture.example/basics/", "site.link.prose.cross-site")
            }

            Step(
                "a declared site builds into an artifact tree"
            ) {
                let tree = try FixtureHome.artifactTree { page, _ in
                    PageRenderOutput(
                        document: HTMLDocument(
                            attributes: .empty,
                            head: [],
                            body: [HTML.text(page.title)]
                        )
                    )
                }

                try Expect.equal(
                    tree.entries.map { $0.path.rendered(asRootPath: false) },
                    ["index.html", "offer/index.html", "offer/consult/index.html", "assets/css/site.css"],
                    "site.tree.artifacts"
                )
            }
        }
}
