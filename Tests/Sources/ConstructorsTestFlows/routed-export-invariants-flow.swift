import Constructors
import HTML
import Primitives
import Path
import TestFlows

private enum RoutedExportFixtureIdentifier: String, DeclarationIdentifier {
    case sample
}

private enum RoutedExportFixtureError: Error {
    case unexpectedEvaluation
}

private func fixtureRoutedExport(
    _ id: ExportKey,
    route: BundleExportRoute
) -> RoutedBundleExportDefinition {
    RoutedBundleExportDefinition(
        id: id,
        route: route
    ) { _, _ in
        throw RoutedExportFixtureError.unexpectedEvaluation
    }
}

extension ConstructorsFlowSuite {
    static let routedExportInvariants = TestFlow(
        "routed-export-invariants",
        title: "Route-bearing declarations preserve required route identity through their legacy export projection",
        tags: ["constructors", "declaration", "invariant", "route"]
    ) {
        Step("document, snippet, style, and site-document declarations have a required route") {
            let route = BundleExportRoute(
                output: StandardPath(["pages", "sample.html"])
            )

            let document = DocumentDeclaration<RoutedExportFixtureIdentifier>(
                id: .sample,
                export: fixtureRoutedExport(.document("sample"), route: route)
            )
            let snippet = SnippetDeclaration<RoutedExportFixtureIdentifier>(
                id: .sample,
                export: fixtureRoutedExport(.snippet("sample"), route: route)
            )
            let style = StyleDeclaration<RoutedExportFixtureIdentifier>(
                id: .sample,
                export: fixtureRoutedExport(.stylesheet("sample"), route: route)
            )
            let siteDocument = SiteDocumentDefinition(
                id: "sample",
                export: fixtureRoutedExport(.document("sample"), route: route)
            )

            try Expect.equal(document.route, route, "routed.document.route")
            try Expect.equal(document.export.route, Optional(route), "routed.document.export-route")
            try Expect.equal(snippet.route, route, "routed.snippet.route")
            try Expect.equal(snippet.export.route, Optional(route), "routed.snippet.export-route")
            try Expect.equal(style.route, route, "routed.style.route")
            try Expect.equal(style.export.route, Optional(route), "routed.style.export-route")
            try Expect.equal(siteDocument.route, route, "routed.site-document.route")
            try Expect.equal(siteDocument.export.route, Optional(route), "routed.site-document.export-route")
        }

        Step("contextual page construction selects content before serialization") {
            let target = PageTarget(
                htmlForEnvironment: { environment in
                    HTML.document {
                        HTML.html {
                            HTML.head {}
                            HTML.body {
                                HTML.text(
                                    environment == .public
                                        ? "public-content"
                                        : "nonpublic-content"
                                )
                            }
                        }
                    }
                },
                output: StandardPath(["environment.html"])
            )

            let publicHTML = try target.document(in: .public).render(default: .pretty)
            let localHTML = try target.document(in: .local).render(default: .pretty)
            let testHTML = try target.document(in: .test).render(default: .pretty)

            try Expect.equal(publicHTML.contains("public-content"), true, "page-target.public-content")
            try Expect.equal(publicHTML.contains("nonpublic-content"), false, "page-target.no-private-content")
            try Expect.equal(localHTML.contains("nonpublic-content"), true, "page-target.local-content")
            try Expect.equal(testHTML.contains("nonpublic-content"), true, "page-target.test-content")
        }
    }
}
