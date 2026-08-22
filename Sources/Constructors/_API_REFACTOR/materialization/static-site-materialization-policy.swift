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
