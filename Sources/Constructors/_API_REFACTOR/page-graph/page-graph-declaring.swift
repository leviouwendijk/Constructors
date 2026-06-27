import Primitives

public protocol PageGraphDeclaring: SiteDeclaring {
    associatedtype PageNode: PageGraphNode

    static var pageGraph: PageGraph<PageNode> { get }

    static func export(
        for page: ResolvedPage<PageNode>
    ) throws -> BundleExportDefinition
}

public extension PageGraphDeclaring {
    static func declaration_exports() throws -> [BundleExportDefinition] {
        try pageGraph
            .resolved()
            .map { page in
                try export(
                    for: page
                )
            }
    }

    static func declaration_navigation(
        env: BuildEnvironment,
        sort_order: NavigationSortOrder = .insertion
    ) throws -> NavigationStructure {
        try pageGraph.navigation(
            in: env
        )
    }
}
