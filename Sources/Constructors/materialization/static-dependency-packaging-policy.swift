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

/// How authored (inline) scripts are delivered. External scripts are
/// dependencies by URL and always stay external.
public struct StaticJavaScriptPackagingPolicy:
    Sendable
{
    public enum Delivery:
        Sendable,
        Equatable
    {
        /// Every script as written: inline stays inline.
        case preserve
        /// Each authored script in its own file, named by its identifier;
        /// a document loads only its own.
        case files
        /// Authored scripts that load the same way (classic or module,
        /// `defer`, `async`) share one site file per loading class, in site
        /// order. Module scripts are never combined, since top-level
        /// bindings of two modules can clash; each gets its own file.
        case bundled
    }

    public let delivery:
        Delivery

    public let paths:
        ArtifactPathProfile

    public init(
        delivery:
            Delivery = .preserve,
        paths:
            ArtifactPathProfile = .standard
    ) {
        self.delivery =
            delivery

        self.paths =
            paths
    }

    public static var preserve: Self {
        .init()
    }
}

/// Which catalogued assets reach the export.
public struct StaticAssetPackagingPolicy:
    Sendable
{
    public enum Emission:
        Sendable,
        Equatable
    {
        /// Every asset in the catalog.
        case all
        /// Only assets some page declared it uses.
        case used
    }

    public let catalog:
        ArtifactAssetCatalog

    public let emission:
        Emission

    public init(
        catalog:
            ArtifactAssetCatalog = .empty,
        emission:
            Emission = .all
    ) {
        self.catalog =
            catalog

        self.emission =
            emission
    }
}

public struct StaticDependencyPackagingPolicy:
    Sendable
{
    public let styles:
        StaticStylesheetPackagingPolicy

    public let scripts:
        StaticJavaScriptPackagingPolicy

    public let assets:
        StaticAssetPackagingPolicy

    public init(
        styles:
            StaticStylesheetPackagingPolicy =
                .init(),
        scripts:
            StaticJavaScriptPackagingPolicy =
                .preserve,
        assets:
            StaticAssetPackagingPolicy =
                .init()
    ) {
        self.assets =
            assets

        self.styles =
            styles

        self.scripts =
            scripts
    }
}
