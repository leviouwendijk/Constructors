import Primitives

public struct BundleExportDefinition: Sendable {
    public let id: ExportKey
    public let route: BundleExportRoute?

    private let _evaluate: @Sendable (
        BuildContext,
        any SiteReferenceResolving
    ) throws -> EvaluatedBundleExport

    public init(
        id: ExportKey,
        route: BundleExportRoute? = nil,
        evaluate: @escaping @Sendable (
            BuildContext,
            any SiteReferenceResolving
        ) throws -> EvaluatedBundleExport
    ) {
        self.id = id
        self.route = route
        self._evaluate = evaluate
    }

    public var visibility: Set<BuildEnvironment> {
        route?.visibility ?? [.local, .test, .public]
    }

    public var metadata: TargetMetadata? {
        route?.metadata
    }

    public func evaluate(
        context: BuildContext,
        references: any SiteReferenceResolving
    ) throws -> EvaluatedBundleExport {
        try _evaluate(context, references)
            .identified(id)
            .withRoute(route)
            .withVisibility(visibility)
            .withMetadata(metadata)
    }
}

// public struct BundleExportDefinition: Sendable {
//     public let id: String
//     public let visibility: Set<BuildEnvironment>
//     public let metadata: TargetMetadata?

//     private let _evaluate: @Sendable (BuildContext) throws -> EvaluatedBundleExport

//     public init(
//         id: String,
//         visibility: Set<BuildEnvironment> = [.local, .test, .public],
//         metadata: TargetMetadata? = nil,
//         evaluate: @escaping @Sendable (BuildContext) throws -> EvaluatedBundleExport
//     ) {
//         self.id = id
//         self.visibility = visibility
//         self.metadata = metadata
//         self._evaluate = evaluate
//     }

//     public func evaluate(
//         context: BuildContext
//     ) throws -> EvaluatedBundleExport {
//         try _evaluate(context)
//             .identified(id)
//             .withVisibility(visibility)
//             .withMetadata(metadata)
//     }
// }
