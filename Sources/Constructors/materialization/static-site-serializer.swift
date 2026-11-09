import CSS
import HTML
import Primitives

/// Terminal write-free serialization for the static-materialization branch.
///
/// Required ordering:
///
///     rendered structural site
///         -> physical output planning
///         -> dependency packaging
///         -> document dependency integration
///         -> terminal HTML/CSS serialization
///         -> later delivery
///
/// This type is the first Constructors static-materialization layer allowed to
/// convert `HTMLDocument` and `CSSStyleSheet` into `String`.
public struct StaticSiteSerializer:
    Sendable
{
    public let policy:
        StaticSerializationPolicy

    public init(
        policy:
            StaticSerializationPolicy =
                .init()
    ) {
        self.policy =
            policy
    }

    public func serialize<
        Identifier:
            StringIdentifier
    >(
        _ source:
            StaticIntegratedDocumentArtifact<Identifier>
    ) -> StaticSerializedDocumentArtifact<Identifier> {
        StaticSerializedDocumentArtifact(
            source:
                source,
            artifact:
                StaticTextArtifact(
                    output:
                        source
                            .output,
                    contents:
                        source
                            .document
                            .render(
                                options:
                                    policy
                                        .html
                            )
                )
        )
    }

    public func serialize(
        _ source:
            StaticStylesheetArtifactPlan
    ) -> StaticSerializedStylesheetArtifact {
        StaticSerializedStylesheetArtifact(
            source:
                source,
            artifact:
                StaticTextArtifact(
                    output:
                        source
                            .output,
                    contents:
                        source
                            .stylesheet
                            .render(
                                options:
                                    policy
                                        .stylesheet
                            )
                )
        )
    }

    public func serialize<
        Page:
            PageGraphNode
    >(
        _ source:
            StaticIntegratedSiteMaterializationPlan<Page>
    ) -> StaticSerializedSiteMaterialization<Page> {
        StaticSerializedSiteMaterialization(
            source:
                source,
            documents:
                source
                    .documents
                    .map {
                        serialize(
                            $0
                        )
                    },
            stylesheet:
                serialize(
                    source
                        .source
                        .dependencies
                        .stylesheet
                )
        )
    }
}
