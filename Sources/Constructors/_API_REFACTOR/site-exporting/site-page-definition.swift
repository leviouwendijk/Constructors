import HTML
import Path
import Primitives

public struct SiteDocumentDefinition: Sendable {
    public let id: String
    public let navigation: NavigationSetting
    public let export: BundleExportDefinition

    public init(
        id: String,
        navigation: NavigationSetting = .none,
        export: BundleExportDefinition
    ) {
        self.id = id
        self.navigation = navigation
        self.export = export
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
        self.export = BundleExportDefinition(
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
            BuildContext,
            any SiteReferenceResolving
        ) throws -> DocumentEvaluationOptions = { _, _ in .default },
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
                "SiteDocumentDefinition requires an export route."
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
            navigation: navigation
        ) { _ in
            self.bundle()
        }
    }
}
