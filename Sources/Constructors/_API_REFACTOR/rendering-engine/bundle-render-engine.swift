public struct BundleRenderEngine {
    public let context: BuildContext
    public let writer: OutputWriter

    public init(
        context: BuildContext
    ) {
        self.context = context
        self.writer = OutputWriter(context: context)
    }

    public func evaluate(
        _ definitions: [BundleExportDefinition]
    ) throws -> EvaluatedExportSet {
        let evaluated = try definitions.compactMap { definition -> EvaluatedBundleExport? in
            guard definition.visibility.contains(context.env) else {
                return nil
            }

            return try definition.evaluate(context: context)
        }

        return EvaluatedExportSet(evaluated)
    }

    @discardableResult
    public func write(
        _ definitions: [BundleExportDefinition]
    ) throws -> EvaluatedExportSet {
        let evaluated = try evaluate(definitions)
        try writer.write(evaluated)
        return evaluated
    }

    @discardableResult
    public func build(
        _ definitions: [BundleExportDefinition],
        writeMetadata: Bool = true
    ) throws -> EvaluatedExportSet {
        try context.env.pull_assets(for: context.site)

        let evaluated = try write(definitions)

        if writeMetadata {
            try MetadataWriter(context: context).write(
                from: evaluated
            )
        }

        return evaluated
    }
}
