/// Static document output planning.
///
/// This stage deliberately stops before dependency integration, terminal
/// serialization, and filesystem mutation.
///
/// It performs only the first static lowering:
///
///     logical SiteRoute
///         -> physical StandardPath
///
/// `HTMLDocument` and per-document `RenderDependencies` remain structural so
/// later materialization stages can integrate packaged stylesheet/script
/// dependencies without rewriting serialized HTML.
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
    ) throws -> StaticDocumentArtifact<
        Page.PageIdentifier
    > {
        try StaticDocumentArtifact(
            identifier:
                document.identifier,
            route:
                document.route,
            output:
                try policy
                    .documentOutput(
                        for:
                            document.route
                    ),
            document:
                document
                    .document,
            dependencies:
                document
                    .dependencies,
            head:
                document
                    .head
        )
    }

    public func materialize<
        Page:
            PageGraphNode
    >(
        _ site:
            SiteRenderResult<Page>
    ) throws -> StaticSiteDocumentMaterialization<Page> {
        try StaticSiteDocumentMaterialization(
            projection:
                site.projection,
            documents:
                site
                    .documents
                    .map {
                        try materialize(
                            $0
                        )
                    },
            dependencies:
                site.dependencies
        )
    }
}
