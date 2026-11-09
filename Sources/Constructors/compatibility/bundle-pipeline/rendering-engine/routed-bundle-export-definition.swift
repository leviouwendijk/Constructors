import Primitives

/// A route-bearing export that cannot be declared without a destination.
/// Projection to BundleExportDefinition preserves the older engine's API.
public struct RoutedBundleExportDefinition: Sendable {
    public let id: ExportKey
    public let route: BundleExportRoute

    private let _evaluate: @Sendable (
        BuildContext,
        any SiteReferenceResolving
    ) throws -> EvaluatedBundleExport

    public init(
        id: ExportKey,
        route: BundleExportRoute,
        evaluate: @escaping @Sendable (
            BuildContext,
            any SiteReferenceResolving
        ) throws -> EvaluatedBundleExport
    ) {
        self.id = id
        self.route = route
        self._evaluate = evaluate
    }

    public var export: BundleExportDefinition {
        BundleExportDefinition(
            id: id,
            route: route,
            evaluate: _evaluate
        )
    }
}
