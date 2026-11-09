import Primitives
import Path

public protocol SiteReferenceResolving: Sendable {
    var sourceSite: any SiteResolvable { get }

    func route_graph(
        for destinationSite: any SiteResolvable
    ) throws -> SiteRouteGraph

    func output(
        _ key: ExportKey,
        on destinationSite: any SiteResolvable
    ) throws -> StandardPath

    func refer(
        _ key: ExportKey,
        on destinationSite: any SiteResolvable,
        style: SiteReferenceStyle
    ) throws -> String

    func asset_reference(
        _ key: ExportKey,
        on destinationSite: any SiteResolvable,
        style: SiteReferenceStyle
    ) throws -> HTMLAssetReference
}

public extension SiteReferenceResolving {
    func output<Key: TypedSiteExportKey>(
        _ key: Key
    ) throws -> StandardPath {
        try output(
            key.export_key,
            on: key.site
        )
    }

    func refer<Key: TypedSiteExportKey>(
        _ key: Key,
        style: SiteReferenceStyle = .automatic
    ) throws -> String {
        try refer(
            key.export_key,
            on: key.site,
            style: style
        )
    }

    func asset_reference<Key: TypedSiteExportKey>(
        _ key: Key,
        style: SiteReferenceStyle = .automatic
    ) throws -> HTMLAssetReference {
        try asset_reference(
            key.export_key,
            on: key.site,
            style: style
        )
    }
}

public struct DeclaredSiteReferenceResolver: SiteReferenceResolving {
    public let sourceGraph: SiteRouteGraph

    public init(
        sourceGraph: SiteRouteGraph
    ) {
        self.sourceGraph = sourceGraph
    }

    public var sourceSite: any SiteResolvable {
        sourceGraph.site
    }

    public func route_graph(
        for destinationSite: any SiteResolvable
    ) throws -> SiteRouteGraph {
        if destinationSite.site_id == sourceGraph.site.site_id {
            return sourceGraph
        }

        let siteObject = try destinationSite.site_object()
        let definitions = try siteObject.export_definitions()

        return SiteRouteGraph(
            site: destinationSite,
            exports: Dictionary(
                uniqueKeysWithValues: definitions.map { definition in
                    (
                        definition.id,
                        definition
                    )
                }
            ),
            env: sourceGraph.env
        )
    }

    public func output(
        _ key: ExportKey,
        on destinationSite: any SiteResolvable
    ) throws -> StandardPath {
        try route_graph(
            for: destinationSite
        ).output(key)
    }

    public func refer(
        _ key: ExportKey,
        on destinationSite: any SiteResolvable,
        style: SiteReferenceStyle = .automatic
    ) throws -> String {
        let destinationGraph = try route_graph(
            for: destinationSite
        )

        return try sourceGraph.refer(
            key,
            on: destinationGraph,
            style: style
        )
    }

    public func asset_reference(
        _ key: ExportKey,
        on destinationSite: any SiteResolvable,
        style: SiteReferenceStyle = .automatic
    ) throws -> HTMLAssetReference {
        let destinationGraph = try route_graph(
            for: destinationSite
        )

        return try sourceGraph.asset_reference(
            key,
            on: destinationGraph,
            style: style
        )
    }
}
