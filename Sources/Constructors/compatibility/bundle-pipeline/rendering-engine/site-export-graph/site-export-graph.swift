import Path

public struct SiteExportGraph: Sendable {
    public let context: BuildContext
    public let evaluated: EvaluatedExportSet

    public init(
        context: BuildContext,
        evaluated: EvaluatedExportSet
    ) {
        self.context = context
        self.evaluated = evaluated
    }
}

public extension SiteExportGraph {
    var site: any SiteResolvable {
        context.site
    }

    var exports: [EvaluatedBundleExport] {
        evaluated.exports
    }

    subscript(
        _ key: ExportKey
    ) -> EvaluatedBundleExport? {
        evaluated[key]
    }

    func export(
        _ key: ExportKey
    ) throws -> EvaluatedBundleExport {
        guard let export = self[key] else {
            throw SiteExportGraphError.exportNotFound(
                key: key,
                siteID: site.site_id
            )
        }

        return export
    }

    func route(
        _ key: ExportKey
    ) throws -> BundleExportRoute {
        guard let route = try export(key).route else {
            throw SiteExportGraphError.exportHasNoRoute(
                key: key
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
        on destination: SiteExportGraph,
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
        on destination: SiteExportGraph,
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

public extension SiteExportGraph {
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
        on destinationGraph: SiteExportGraph,
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
        on destinationGraph: SiteExportGraph,
        style: SiteReferenceStyle = .automatic
    ) throws -> HTMLAssetReference {
        try asset_reference(
            key.export_key,
            on: destinationGraph,
            style: style
        )
    }
}
