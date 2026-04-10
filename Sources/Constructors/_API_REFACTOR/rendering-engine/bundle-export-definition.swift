import Primitives

public struct BundleExportDefinition: Sendable {
    public let id: String
    public let visibility: Set<BuildEnvironment>
    public let metadata: TargetMetadata?

    private let _evaluate: @Sendable (BuildContext) throws -> EvaluatedBundleExport

    public init(
        id: String,
        visibility: Set<BuildEnvironment> = [.local, .test, .public],
        metadata: TargetMetadata? = nil,
        evaluate: @escaping @Sendable (BuildContext) throws -> EvaluatedBundleExport
    ) {
        self.id = id
        self.visibility = visibility
        self.metadata = metadata
        self._evaluate = evaluate
    }

    public func evaluate(
        context: BuildContext
    ) throws -> EvaluatedBundleExport {
        try _evaluate(context)
            .identified(id)
            .withVisibility(visibility)
            .withMetadata(metadata)
    }
}
