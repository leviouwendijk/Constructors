import Primitives
import Path

public struct SiteRouteGraph: Sendable {
    public let site: any SiteResolvable
    public let env: BuildEnvironment?
    public let exports: [ExportKey: BundleExportDefinition]

    public init(
        site: any SiteResolvable,
        exports: [ExportKey: BundleExportDefinition],
        env: BuildEnvironment? = nil
    ) {
        self.site = site
        self.exports = exports
        self.env = env
    }
}

public extension SiteRouteGraph {
    subscript(
        _ key: ExportKey
    ) -> BundleExportDefinition? {
        exports[key]
    }

    func definition(
        _ key: ExportKey
    ) throws -> BundleExportDefinition {
        guard let definition = exports[key] else {
            throw SiteExportGraphError.exportNotFound(
                key: key,
                siteID: site.site_id
            )
        }

        return definition
    }

    func route(
        _ key: ExportKey
    ) throws -> BundleExportRoute {
        let definition = try definition(key)

        guard let route = definition.route else {
            throw SiteExportGraphError.exportHasNoRoute(
                key: key
            )
        }

        if let env, !definition.visibility.contains(env) {
            throw SiteExportGraphError.exportNotFound(
                key: key,
                siteID: site.site_id
            )
        }

        return route
    }

    func output(
        _ key: ExportKey
    ) throws -> StandardPath {
        try route(key).output
    }

    func refer(
        _ key: ExportKey,
        style: SiteReferenceStyle = .automatic
    ) throws -> String {
        try refer(
            key,
            on: self,
            style: style
        )
    }

    func refer(
        _ key: ExportKey,
        on destination: SiteRouteGraph,
        style: SiteReferenceStyle = .automatic
    ) throws -> String {
        let path = try destination.output(key)

        return resolve_site_reference(
            sourceSite: site,
            destinationSite: destination.site,
            path: path,
            style: style
        )
    }

    func asset_reference(
        _ key: ExportKey,
        style: SiteReferenceStyle = .automatic
    ) throws -> HTMLAssetReference {
        try asset_reference(
            key,
            on: self,
            style: style
        )
    }

    func asset_reference(
        _ key: ExportKey,
        on destination: SiteRouteGraph,
        style: SiteReferenceStyle = .automatic
    ) throws -> HTMLAssetReference {
        let path = try destination.output(key)

        return resolve_site_asset_reference(
            sourceSite: site,
            destinationSite: destination.site,
            path: path,
            style: style
        )
    }
}

public extension SiteRouteGraph {
    func output<Key: TypedSiteExportKey>(
        _ key: Key
    ) throws -> StandardPath {
        try output(
            key.export_key
        )
    }

    func refer<Key: TypedSiteExportKey>(
        _ key: Key,
        style: SiteReferenceStyle = .automatic
    ) throws -> String {
        try refer(
            key.export_key,
            style: style
        )
    }

    func refer<Key: TypedSiteExportKey>(
        to key: Key,
        on destinationGraph: SiteRouteGraph,
        style: SiteReferenceStyle = .automatic
    ) throws -> String {
        try refer(
            key.export_key,
            on: destinationGraph,
            style: style
        )
    }

    func asset_reference<Key: TypedSiteExportKey>(
        _ key: Key,
        style: SiteReferenceStyle = .automatic
    ) throws -> HTMLAssetReference {
        try asset_reference(
            key.export_key,
            style: style
        )
    }

    func asset_reference<Key: TypedSiteExportKey>(
        to key: Key,
        on destinationGraph: SiteRouteGraph,
        style: SiteReferenceStyle = .automatic
    ) throws -> HTMLAssetReference {
        try asset_reference(
            key.export_key,
            on: destinationGraph,
            style: style
        )
    }
}
