import Path
import Primitives

/// A filesystem-oriented textual artifact that is ready to be delivered but
/// has not itself been written anywhere.
///
/// This is deliberately small enough to become the input of a later static
/// writer without requiring that writer to know HTML, CSS, site routes,
/// contributions, or rendering semantics.
public struct StaticTextArtifact:
    Sendable,
    Equatable
{
    public let output:
        StandardPath

    public let contents:
        String

    public init(
        output:
            StandardPath,
        contents:
            String
    ) {
        self.output =
            output

        self.contents =
            contents
    }
}

/// Serialized HTML plus the still-available integrated semantic provenance
/// from which that terminal payload was derived.
public struct StaticSerializedDocumentArtifact<
    Identifier:
        StringIdentifier
>:
    Sendable
{
    public let source:
        StaticIntegratedDocumentArtifact<Identifier>

    public let artifact:
        StaticTextArtifact

    public init(
        source:
            StaticIntegratedDocumentArtifact<Identifier>,
        artifact:
            StaticTextArtifact
    ) {
        self.source =
            source

        self.artifact =
            artifact
    }

    public var identifier:
        Identifier
    {
        source
            .identifier
    }

    public var route:
        SiteRoute
    {
        source
            .route
    }

    public var output:
        StandardPath
    {
        artifact
            .output
    }

    public var contents:
        String
    {
        artifact
            .contents
    }
}

/// Serialized stylesheet payload plus its structural packaging provenance.
public struct StaticSerializedStylesheetArtifact:
    Sendable
{
    public let source:
        StaticStylesheetArtifactPlan

    public let artifact:
        StaticTextArtifact

    public init(
        source:
            StaticStylesheetArtifactPlan,
        artifact:
            StaticTextArtifact
    ) {
        self.source =
            source

        self.artifact =
            artifact
    }

    public var output:
        StandardPath
    {
        artifact
            .output
    }

    public var contents:
        String
    {
        artifact
            .contents
    }
}

/// Complete generated textual artifact set for one integrated static site.
///
/// `source` intentionally remains available for diagnostics and provenance.
/// `artifacts` is the narrow delivery-facing view that a later filesystem
/// writer can consume without performing any additional serialization.
public struct StaticSerializedSiteMaterialization<
    Page:
        PageGraphNode
>:
    Sendable
{
    public let source:
        StaticIntegratedSiteMaterializationPlan<Page>

    public let documents:
        [
            StaticSerializedDocumentArtifact<
                Page.PageIdentifier
            >
        ]

    public let stylesheet:
        StaticSerializedStylesheetArtifact

    public init(
        source:
            StaticIntegratedSiteMaterializationPlan<Page>,
        documents:
            [
                StaticSerializedDocumentArtifact<
                    Page.PageIdentifier
                >
            ],
        stylesheet:
            StaticSerializedStylesheetArtifact
    ) {
        self.source =
            source

        self.documents =
            documents

        self.stylesheet =
            stylesheet
    }

    /// Stable generated-artifact order:
    ///
    /// 1. projected documents in their existing site order;
    /// 2. the packaged stylesheet.
    ///
    /// External JavaScript references are intentionally not manufactured into
    /// generated artifacts here. Inline JavaScript is already represented in
    /// the serialized HTML document.
    public var artifacts:
        [StaticTextArtifact]
    {
        documents
            .map(
                \.artifact
            )
            + [
                stylesheet
                    .artifact,
            ]
    }
}
