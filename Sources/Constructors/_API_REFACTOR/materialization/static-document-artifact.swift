import Path
import Primitives

/// One rendered document after static output identity and HTML serialization
/// have been chosen, but before any filesystem write occurs.
///
/// Semantic provenance is intentionally retained beside the physical output so
/// diagnostics and later materializers do not need to reverse-engineer page
/// identity from a filename.
public struct StaticDocumentArtifact<
    Identifier:
        StringIdentifier
>:
    Sendable
{
    public let identifier:
        Identifier

    public let route:
        SiteRoute

    public let output:
        StandardPath

    public let serializedHTML:
        String

    public init(
        identifier:
            Identifier,
        route:
            SiteRoute,
        output:
            StandardPath,
        serializedHTML:
            String
    ) {
        self.identifier =
            identifier

        self.route =
            route

        self.output =
            output

        self.serializedHTML =
            serializedHTML
    }
}

/// Document-only static materialization of one rendered site.
///
/// CSS and JavaScript remain rich resolved dependencies. Their packaging
/// strategy is deliberately deferred: this pass does not assume that all
/// scripts can be concatenated, externalized, inlined, or represented by one
/// generated file.
public struct StaticSiteDocumentMaterialization<
    Page:
        PageGraphNode
>:
    Sendable
{
    public let projection:
        SiteProjection<Page>

    public let documents:
        [
            StaticDocumentArtifact<
                Page.PageIdentifier
            >
        ]

    public let dependencies:
        RenderDependencies

    init(
        projection:
            SiteProjection<Page>,
        documents:
            [
                StaticDocumentArtifact<
                    Page.PageIdentifier
                >
            ],
        dependencies:
            RenderDependencies
    ) {
        self.projection =
            projection

        self.documents =
            documents

        self.dependencies =
            dependencies
    }
}
