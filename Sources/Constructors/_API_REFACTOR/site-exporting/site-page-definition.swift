import HTML
import Path
import Primitives

public struct SiteDocumentDefinition: Sendable {
    public let id: String
    public let output: StandardPath
    public let visibility: Set<BuildEnvironment>
    public let metadata: TargetMetadata?
    public let navigation: NavigationSetting
    public let export: BundleExportDefinition

    public init(
        id: String,
        output: StandardPath,
        visibility: Set<BuildEnvironment> = [.local, .test, .public],
        metadata: TargetMetadata? = nil,
        navigation: NavigationSetting = .none,
        export: BundleExportDefinition
    ) {
        self.id = id
        self.output = output
        self.visibility = visibility
        self.metadata = metadata
        self.navigation = navigation
        self.export = export
    }
}

public extension SiteDocumentDefinition {
    func evaluate(
        context: BuildContext
    ) throws -> EvaluatedBundleExport {
        try export.evaluate(
            context: context
        )
        .withRoute(
            BundleExportRoute(
                output: output,
                visibility: visibility,
                metadata: metadata
            )
        )
        .withVisibility(visibility)
        .withMetadata(metadata)
    }
}

public extension PageTarget {
    func document_definition(
        id: String
    ) -> SiteDocumentDefinition {
        let bundle = self.bundle()

        let export = BundleExportDefinition(
            id: id,
            visibility: visibility,
            metadata: metadata
        ) { context in
            bundle.export.document.html.evaluate(
                route: nil,
                environment: context.env
            )
        }

        return SiteDocumentDefinition(
            id: id,
            output: output,
            visibility: visibility,
            metadata: metadata,
            navigation: navigation,
            export: export
        )
    }
}
