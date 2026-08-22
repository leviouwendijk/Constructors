import Primitives

/// Legacy adapter from the canonical PageGraph pipeline into the older
/// SiteDeclaring / BundleExportDefinition consumer surface.
///
/// This protocol remains active only while BuildV2 still consumes
/// `SiteDeclaring`. It must not become a second canonical execution path.
public protocol PageGraphDeclaring:
    SiteDeclaring
{
    associatedtype PageNode:
        PageGraphNode

    static var pageGraph:
        PageGraph<PageNode>
    {
        get
    }

    static func export(
        for page:
            ResolvedPage<PageNode>
    ) throws -> BundleExportDefinition
}

public extension PageGraphDeclaring {
    static func declaration_exports()
        throws -> [BundleExportDefinition]
    {
        try pageGraph
            .resolve()
            .pages
            .map { page in
                try export(
                    for:
                        page
                )
            }
    }

    static func declaration_navigation(
        env:
            BuildEnvironment,
        sort_order:
            NavigationSortOrder = .insertion
    ) throws -> NavigationStructure {
        try pageGraph
            .resolve()
            .project(
                in:
                    env
            )
            .navigation(
                sortOrder:
                    sort_order
            )
    }
}
