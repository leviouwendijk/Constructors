import Path
import Primitives

public struct StyleDeclaration<Identifier: DeclarationIdentifier>: Sendable {
    public let id: Identifier
    public let export: BundleExportDefinition

    public init(
        id: Identifier,
        export: BundleExportDefinition
    ) {
        self.id = id
        self.export = export
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
        self.export = BundleExportDefinition(
            id: .stylesheet(id.rawValue),
            route: route,
            evaluate: evaluate
        )
    }

    public var route: BundleExportRoute {
        guard let route = export.route else {
            preconditionFailure(
                "StyleDeclaration requires an export route."
            )
        }

        return route
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
