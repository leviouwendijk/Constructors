import HTML
import Path
import Primitives

/// One rendered document after static output identity has been chosen, but
/// before dependency integration, terminal serialization, or filesystem write.
///
/// Semantic provenance and per-document dependency state remain beside the
/// physical output so later materialization stages do not need to reconstruct
/// either from site-wide state or from a filename.
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

    /// Still-structural document representation.
    public let document:
        HTMLDocument

    /// Dependencies belonging to this document specifically.
    ///
    /// Site-wide packaging may deduplicate contributions, but document-local
    /// membership and ordering remain authoritative when those packaged
    /// dependencies are integrated into the document.
    public let dependencies:
        RenderDependencies

    public init(
        identifier:
            Identifier,
        route:
            SiteRoute,
        output:
            StandardPath,
        document:
            HTMLDocument,
        dependencies:
            RenderDependencies
    ) {
        self.identifier =
            identifier

        self.route =
            route

        self.output =
            output

        self.document =
            document

        self.dependencies =
            dependencies
    }
}

/// Document-output planning for one rendered site.
///
/// Site-wide resolved dependency identity remains available for packaging,
/// while every document also retains its own resolved dependency membership.
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
