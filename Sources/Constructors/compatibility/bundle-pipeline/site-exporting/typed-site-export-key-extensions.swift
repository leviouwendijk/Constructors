public extension BundleHTMLDocumentStyle {
    @available(
        *,
        deprecated,
        message: """
        Prefer BundleHTMLDocumentStyle.linked(using:resolver, ...) inside a resolver-aware document builder.
        """
    )
    static func linked<Site: SiteDeclaring>(
        _ styles: [SiteStyleKey<Site>],
        style referenceStyle: SiteReferenceStyle = .automatic
    ) -> Self {
        .linked(
            styles.map {
                Site.asset_reference(
                    $0,
                    style: referenceStyle
                )
            }
        )
    }

    @available(
        *,
        deprecated,
        message: """
        Prefer BundleHTMLDocumentStyle.linked(using:resolver, ...) inside a resolver-aware document builder.
        """
    )
    static func linked<Source: SiteObject, Destination: SiteDeclaring>(
        from source: Source.Type,
        _ styles: [SiteStyleKey<Destination>],
        style referenceStyle: SiteReferenceStyle = .automatic
    ) -> Self {
        .linked(
            styles.map {
                source.asset_reference(
                    $0,
                    style: referenceStyle
                )
            }
        )
    }

    static func linked<Site: SiteDeclaring>(
        using resolver: any SiteReferenceResolving,
        _ styles: [SiteStyleKey<Site>],
        style referenceStyle: SiteReferenceStyle = .automatic
    ) throws -> Self {
        .linked(
            try styles.map {
                try resolver.asset_reference(
                    $0,
                    style: referenceStyle
                )
            }
        )
    }
}
