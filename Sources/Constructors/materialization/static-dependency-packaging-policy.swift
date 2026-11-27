import DSL
import FileTypes
import Path

/// The site stylesheet: which bundle it is and where bundles go.
public struct StaticStylesheetPackagingPolicy:
    Sendable
{
    public let bundle:
        ArtifactBundle

    public let paths:
        ArtifactPathProfile

    public let selection:
        ScopeSelection

    public init(
        bundle:
            ArtifactBundle = .site,
        paths:
            ArtifactPathProfile = .standard,
        selection:
            ScopeSelection =
                .all
    ) {
        self.bundle =
            bundle

        self.paths =
            paths

        self.selection =
            selection
    }

    /// The stylesheet's planned path: the profile's stylesheet template.
    public func output() throws -> StandardPath {
        try paths
            .stylesheetPath(
                bundle
            )
    }
}

public enum StaticJavaScriptPackagingPolicy:
    Sendable,
    Equatable
{
    /// Preserve every resolved JavaScript contribution as its existing
    /// structural script value.
    ///
    /// Inline/external identity and script attributes remain intact.
    /// A later materialization policy may introduce generated-file packaging
    /// only when its semantic constraints are explicit.
    case preserve
}

public struct StaticDependencyPackagingPolicy:
    Sendable
{
    public let styles:
        StaticStylesheetPackagingPolicy

    public let scripts:
        StaticJavaScriptPackagingPolicy

    public init(
        styles:
            StaticStylesheetPackagingPolicy =
                .init(),
        scripts:
            StaticJavaScriptPackagingPolicy =
                .preserve
    ) {
        self.styles =
            styles

        self.scripts =
            scripts
    }
}
