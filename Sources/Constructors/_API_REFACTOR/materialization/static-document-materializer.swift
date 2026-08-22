/// Static document materialization.
///
/// This type deliberately stops before filesystem mutation and before CSS/JS
/// packaging. It converts already-rendered semantic documents into static
/// document artifacts:
///
///     logical SiteRoute
///         -> physical StandardPath
///
///     HTMLDocument
///         -> terminal HTML String
///
/// Resolved CSS/JS dependency identity remains available for the next
/// materialization stage.
public struct StaticDocumentMaterializer:
    Sendable
{
    public let policy:
        StaticDocumentMaterializationPolicy

    public init(
        policy:
            StaticDocumentMaterializationPolicy =
                .init()
    ) {
        self.policy =
            policy
    }

    public func materialize<
        Page:
            PageGraphNode
    >(
        _ document:
            RenderedDocument<Page>
    ) -> StaticDocumentArtifact<
        Page.PageIdentifier
    > {
        StaticDocumentArtifact(
            identifier:
                document.identifier,
            route:
                document.route,
            output:
                policy
                    .documentOutput(
                        for:
                            document.route
                    ),
            serializedHTML:
                document
                    .document
                    .render(
                        options:
                            policy.html
                    )
        )
    }

    public func materialize<
        Page:
            PageGraphNode
    >(
        _ site:
            SiteRenderResult<Page>
    ) -> StaticSiteDocumentMaterialization<Page> {
        StaticSiteDocumentMaterialization(
            projection:
                site.projection,
            documents:
                site
                    .documents
                    .map {
                        materialize(
                            $0
                        )
                    },
            dependencies:
                site.dependencies
        )
    }
}
