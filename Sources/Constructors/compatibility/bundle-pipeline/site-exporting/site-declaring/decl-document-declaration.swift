import Path
import Primitives

public struct DocumentDeclaration<Identifier: DeclarationIdentifier>: Sendable {
    public let id: Identifier
    public let navigation: NavigationSetting
    public let routedExport: RoutedBundleExportDefinition

    public var export: BundleExportDefinition {
        routedExport.export
    }

    public init(
        id: Identifier,
        navigation: NavigationSetting = .none,
        export: RoutedBundleExportDefinition
    ) {
        self.id = id
        self.navigation = navigation
        self.routedExport = export
    }

    public init(
        id: Identifier,
        route: BundleExportRoute,
        navigation: NavigationSetting = .none,
        evaluate: @escaping @Sendable (
            BuildContext,
            any SiteReferenceResolving
        ) throws -> EvaluatedBundleExport
    ) {
        self.id = id
        self.navigation = navigation
        self.routedExport = RoutedBundleExportDefinition(
            id: .document(id.rawValue),
            route: route,
            evaluate: evaluate
        )
    }

    public init(
        id: Identifier,
        route: BundleExportRoute,
        navigation: NavigationSetting = .none,
        options: @escaping @Sendable (
            BuildContext
        ) throws -> DocumentEvaluationOptions = { _ in
            .default
        },
        build: @escaping @Sendable () throws -> RenderBundle
    ) {
        self.init(
            id: id,
            route: route,
            navigation: navigation
        ) { context, _ in
            let documentOptions = try options(
                context
            )

            return documentOptions.evaluate(
                try build(),
                route: route
            )
        }
    }

    public init(
        id: Identifier,
        route: BundleExportRoute,
        navigation: NavigationSetting = .none,
        options: @escaping @Sendable (
            BuildContext
        ) throws -> DocumentEvaluationOptions = { _ in
            .default
        },
        build: @escaping @Sendable (
            any SiteReferenceResolving
        ) throws -> RenderBundle
    ) {
        self.init(
            id: id,
            route: route,
            navigation: navigation
        ) { context, references in
            let documentOptions = try options(
                context
            )

            return documentOptions.evaluate(
                try build(
                    references
                ),
                route: route
            )
        }
    }

    public init(
        id: Identifier,
        route: BundleExportRoute,
        navigation: NavigationSetting = .none,
        options: @escaping @Sendable (
            BuildContext,
            any SiteReferenceResolving
        ) throws -> DocumentEvaluationOptions = { _, _ in
            .default
        },
        build: @escaping @Sendable (
            any SiteReferenceResolving
        ) throws -> RenderBundle
    ) {
        self.init(
            id: id,
            route: route,
            navigation: navigation
        ) { context, references in
            let documentOptions = try options(
                context,
                references
            )

            return documentOptions.evaluate(
                try build(
                    references
                ),
                route: route
            )
        }
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
