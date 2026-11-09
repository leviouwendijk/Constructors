import HTML
import Path
import Primitives

public struct StaticStylesheetDocumentReference:
    Sendable,
    Equatable
{
    /// Physical artifact identity.
    public let output:
        StandardPath

    /// Public document reference chosen independently from physical output.
    public let href:
        String

    public init(
        output:
            StandardPath,
        href:
            String
    ) {
        self.output =
            output

        self.href =
            href
    }
}

/// One static document after packaged dependencies have been integrated into
/// its structural HTML representation.
///
/// Serialization remains intentionally absent.
public struct StaticIntegratedDocumentArtifact<
    Identifier:
        StringIdentifier
>:
    Sendable
{
    public let source:
        StaticDocumentArtifact<Identifier>

    public let document:
        HTMLDocument

    public let stylesheet:
        StaticStylesheetDocumentReference

    /// Exactly the packaged JavaScript dependencies selected for this document,
    /// in the document's own resolved contribution order.
    public let scripts:
        [StaticJavaScriptDependency]

    public init(
        source:
            StaticDocumentArtifact<Identifier>,
        document:
            HTMLDocument,
        stylesheet:
            StaticStylesheetDocumentReference,
        scripts:
            [StaticJavaScriptDependency]
    ) {
        self.source =
            source

        self.document =
            document

        self.stylesheet =
            stylesheet

        self.scripts =
            scripts
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
        source
            .output
    }
}

public struct StaticIntegratedSiteMaterializationPlan<
    Page:
        PageGraphNode
>:
    Sendable
{
    public let source:
        StaticSiteMaterializationPlan<Page>

    public let documents:
        [
            StaticIntegratedDocumentArtifact<
                Page.PageIdentifier
            >
        ]

    public init(
        source:
            StaticSiteMaterializationPlan<Page>,
        documents:
            [
                StaticIntegratedDocumentArtifact<
                    Page.PageIdentifier
                >
            ]
    ) {
        self.source =
            source

        self.documents =
            documents
    }
}
