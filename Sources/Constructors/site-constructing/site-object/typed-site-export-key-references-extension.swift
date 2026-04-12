public extension SiteObject {
    @available(
        *,
        deprecated,
        message: """
        Prefer resolving typed export keys through a SiteReferenceResolving value inside a resolver-aware document/export builder.
        """
    )
    static func refer<Key: TypedSiteExportKey>(
        _ key: Key,
        style: SiteReferenceStyle = .automatic
    ) -> String {
        do {
            let definitions = try Self.export_definitions()
            let graph = SiteRouteGraph(
                site: Self.site,
                exports: Dictionary(
                    uniqueKeysWithValues: definitions.map { definition in
                        (
                            definition.id,
                            definition
                        )
                    }
                ),
                env: nil
            )

            let resolver = DeclaredSiteReferenceResolver(
                sourceGraph: graph
            )

            return try resolver.refer(
                key,
                style: style
            )
        } catch {
            preconditionFailure(
                "Failed to resolve deprecated direct reference for key '\(key.export_key)': \(error)"
            )
        }
    }

    @available(
        *,
        deprecated,
        message: """
        Prefer resolving typed export keys through a SiteReferenceResolving value inside a resolver-aware document/export builder.
        """
    )
    static func asset_reference<Key: TypedSiteExportKey>(
        _ key: Key,
        style: SiteReferenceStyle = .automatic
    ) -> HTMLAssetReference {
        do {
            let definitions = try Self.export_definitions()
            let graph = SiteRouteGraph(
                site: Self.site,
                exports: Dictionary(
                    uniqueKeysWithValues: definitions.map { definition in
                        (
                            definition.id,
                            definition
                        )
                    }
                ),
                env: nil
            )

            let resolver = DeclaredSiteReferenceResolver(
                sourceGraph: graph
            )

            return try resolver.asset_reference(
                key,
                style: style
            )
        } catch {
            preconditionFailure(
                "Failed to resolve deprecated direct asset reference for key '\(key.export_key)': \(error)"
            )
        }
    }
}
