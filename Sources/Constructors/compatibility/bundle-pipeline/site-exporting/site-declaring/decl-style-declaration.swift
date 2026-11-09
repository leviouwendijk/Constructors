import Path
import Primitives

public struct StyleDeclaration<Identifier: DeclarationIdentifier>: Sendable {
    public let id: Identifier
    public let routedExport: RoutedBundleExportDefinition

    public var export: BundleExportDefinition {
        routedExport.export
    }

    public init(
        id: Identifier,
        export: RoutedBundleExportDefinition
    ) {
        self.id = id
        self.routedExport = export
    }

    public init(
        id: Identifier,
        route: BundleExportRoute,
        evaluate: @escaping @Sendable (
            BuildContext,
            any SiteReferenceResolving
        ) throws -> EvaluatedBundleExport
    ) {
        self.id = id
        self.routedExport = RoutedBundleExportDefinition(
            id: .stylesheet(id.rawValue),
            route: route,
            evaluate: evaluate
        )
    }

    public var route: BundleExportRoute {
        routedExport.route
    }

    public var output: StandardPath {
        route.output
    }

    public var visibility: Set<BuildEnvironment> {
        export.visibility
    }

    public var metadata: TargetMetadata? {
        export.metadata
    }
}
