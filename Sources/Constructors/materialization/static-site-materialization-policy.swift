/// Aggregate policy for the already-separated static materialization stages.
///
/// This value is orchestration configuration, not a new semantic stage.
/// Individual policy types remain authoritative for their own decisions:
///
/// - document output identity;
/// - dependency packaging;
/// - structural document dependency integration;
/// - terminal textual serialization.
///
/// Filesystem destination root is intentionally not stored here. Delivery
/// remains invocation-specific and belongs to `StaticFileWriter`.
public struct StaticSiteMaterializationPolicy:
    Sendable
{
    public let documents:
        StaticDocumentMaterializationPolicy

    public let dependencies:
        StaticDependencyPackagingPolicy

    public let integration:
        StaticDocumentDependencyIntegrationPolicy

    public let serialization:
        StaticSerializationPolicy

    /// Documents, the stylesheet and script files placed by one path
    /// profile; assets come with paths already planned in their catalog.
    public init(
        paths:
            ArtifactPathProfile,
        scripts:
            StaticJavaScriptPackagingPolicy.Delivery =
                .preserve,
        assets:
            StaticAssetPackagingPolicy =
                .init(),
        head:
            Site.Head? = nil,
        integration:
            StaticDocumentDependencyIntegrationPolicy =
                .init(),
        serialization:
            StaticSerializationPolicy =
                .init()
    ) {
        let integration =
            head.map {
                StaticDocumentDependencyIntegrationPolicy(
                    head: $0,
                    inlineScriptPlacement: integration.inlineScriptPlacement,
                    externalScriptPlacement: integration.externalScriptPlacement
                )
            } ?? integration

        let assets =
            StaticAssetPackagingPolicy(
                catalog: assets.catalog,
                emission: assets.emission,
                required: assets.required + (head?.assets ?? [])
            )

        self.init(
            documents:
                .init(
                    paths:
                        paths
                ),
            dependencies:
                .init(
                    styles:
                        .init(
                            paths:
                                paths
                        ),
                    scripts:
                        .init(
                            delivery:
                                scripts,
                            paths:
                                paths
                        ),
                    assets:
                        assets
                ),
            integration:
                integration,
            serialization:
                serialization
        )
    }

    public init(
        documents:
            StaticDocumentMaterializationPolicy =
                .init(),
        dependencies:
            StaticDependencyPackagingPolicy =
                .init(),
        integration:
            StaticDocumentDependencyIntegrationPolicy =
                .init(),
        serialization:
            StaticSerializationPolicy =
                .init()
    ) {
        self.documents =
            documents

        self.dependencies =
            dependencies

        self.integration =
            integration

        self.serialization =
            serialization
    }
}
