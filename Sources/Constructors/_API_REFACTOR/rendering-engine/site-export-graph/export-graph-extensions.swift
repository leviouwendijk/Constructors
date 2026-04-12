public extension BundleRenderEngine {
    func graph(
        _ definitions: [BundleExportDefinition]
    ) throws -> SiteExportGraph {
        SiteExportGraph(
            context: context,
            evaluated: try evaluate(definitions)
        )
    }

    @discardableResult
    func build_graph(
        _ definitions: [BundleExportDefinition],
        writeMetadata: Bool = true
    ) throws -> SiteExportGraph {
        SiteExportGraph(
            context: context,
            evaluated: try build(
                definitions,
                writeMetadata: writeMetadata
            )
        )
    }
}

public extension SiteObject {
    static func export_graph(
        context: BuildContext
    ) throws -> SiteExportGraph {
        try validate_export_graph_context(
            context
        )

        return try BundleRenderEngine(
            context: context
        ).graph(
            export_definitions()
        )
    }

    static func build_export_graph(
        context: BuildContext,
        writeMetadata: Bool = true
    ) throws -> SiteExportGraph {
        try validate_export_graph_context(
            context
        )

        return try BundleRenderEngine(
            context: context
        ).build_graph(
            export_definitions(),
            writeMetadata: writeMetadata
        )
    }
}

private extension SiteObject {
    static func validate_export_graph_context(
        _ context: BuildContext
    ) throws {
        guard context.site.site_id == Self.site.site_id else {
            throw SiteExportGraphError.siteMismatch(
                expected: Self.site.site_id,
                actual: context.site.site_id
            )
        }
    }
}

public extension BundleRenderEngine {
    func route_graph(
        _ definitions: [BundleExportDefinition],
        includeHidden: Bool = false
    ) -> SiteRouteGraph {
        SiteRouteGraph(
            site: context.site,
            exports: Dictionary(
                uniqueKeysWithValues: definitions.map { definition in
                    (
                        definition.id,
                        definition
                    )
                }
            ),
            env: includeHidden ? nil : context.env
        )
    }
}

public extension SiteObject {
    static func route_graph(
        context: BuildContext,
        includeHidden: Bool = false
    ) throws -> SiteRouteGraph {
        try validate_export_graph_context(
            context
        )

        return try BundleRenderEngine(
            context: context
        ).route_graph(
            export_definitions(),
            includeHidden: includeHidden
        )
    }
}
