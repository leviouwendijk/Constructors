import Path
import Primitives

public struct DocumentDeclaration<Identifier: DeclarationIdentifier>: Sendable {
    public let id: Identifier
    public let navigation: NavigationSetting
    public let export: BundleExportDefinition

    public init(
        id: Identifier,
        navigation: NavigationSetting = .none,
        export: BundleExportDefinition
    ) {
        self.id = id
        self.navigation = navigation
        self.export = export
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
        self.export = BundleExportDefinition(
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
                route: route,
                environment: context.env
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
                route: route,
                environment: context.env
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
                route: route,
                environment: context.env
            )
        }
    }

    public var route: BundleExportRoute {
        guard let route = export.route else {
            preconditionFailure(
                "DocumentDeclaration requires an export route."
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
