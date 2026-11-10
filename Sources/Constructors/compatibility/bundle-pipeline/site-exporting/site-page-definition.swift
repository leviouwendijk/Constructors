import HTML
import Path
import Primitives

public struct SiteDocumentDefinition: Sendable {
    public let id: String
    public let navigation: NavigationSetting
    public let routedExport: RoutedBundleExportDefinition

    public var export: BundleExportDefinition {
        routedExport.export
    }

    public init(
        id: String,
        navigation: NavigationSetting = .none,
        export: RoutedBundleExportDefinition
    ) {
        self.id = id
        self.navigation = navigation
        self.routedExport = export
    }

    public init(
        id: String,
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
            id: .document(id),
            route: route,
            evaluate: evaluate
        )
    }

    public init(
        id: String,
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
        id: String,
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
        id: String,
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

    public init(
        id: String,
        route: BundleExportRoute,
        navigation: NavigationSetting = .none,
        options: @escaping @Sendable (BuildContext) throws -> DocumentEvaluationOptions = { _ in
            .default
        },
        buildForEnvironment: @escaping @Sendable (BuildEnvironment) throws -> RenderBundle
    ) {
        self.init(id: id, route: route, navigation: navigation) { context, _ in
            let documentOptions = try options(context)
            return documentOptions.evaluate(
                try buildForEnvironment(context.env),
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

public extension SiteDocumentDefinition {
    func evaluate(
        context: BuildContext,
        references: any SiteReferenceResolving
    ) throws -> EvaluatedBundleExport {
        try export.evaluate(
            context: context,
            references: references
        )
    }
}

public extension PageTarget {
    @available(
        *,
        deprecated,
        message: """
        Prefer declaring documents in SiteDeclaring.declarations() using DocumentDeclaration(id:route:navigation:build:).
        """
    )
    func document_definition(
        id: String
    ) -> SiteDocumentDefinition {
        SiteDocumentDefinition(
            id: id,
            route: BundleExportRoute(
                output: output,
                visibility: visibility,
                metadata: metadata
            ),
            navigation: navigation,
            buildForEnvironment: { environment in
                try self.bundle(in: environment)
            }
        )
    }
}
