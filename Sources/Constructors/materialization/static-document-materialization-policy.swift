import Path

/// Where documents go: the path profile's document template.
public struct StaticDocumentMaterializationPolicy:
    Sendable
{
    public let paths:
        ArtifactPathProfile

    public init(
        paths:
            ArtifactPathProfile = .standard
    ) {
        self.paths =
            paths
    }

    public func documentOutput(
        for route:
            SiteRoute
    ) throws -> StandardPath {
        try paths
            .documentPath(
                route
            )
    }
}
