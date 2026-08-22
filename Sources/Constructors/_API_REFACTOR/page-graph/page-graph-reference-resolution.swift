public extension PageGraph {
    /// Resolve one semantic reference in the context of its source page.
    ///
    /// Successful resolution proves:
    ///
    /// - the source identity exists;
    /// - the destination identity exists;
    /// - both logical routes are known;
    /// - the authoring reference remains available as semantic information.
    ///
    /// No href, `StandardPath`, or HTML value is produced here.
    func resolve(
        _ reference:
            SiteReference<Page.PageIdentifier>,
        from source:
            Page.PageIdentifier
    ) throws -> ResolvedReference<Page.PageIdentifier> {
        let pages =
            try resolved()

        guard
            let resolvedSource =
                pages.first(
                    where: {
                        $0.identifier.rawValue
                            == source.rawValue
                    }
                )
        else {
            throw
                SiteReferenceResolutionError
                    .sourceNotFound(
                        source.rawValue
                    )
        }

        guard
            let resolvedDestination =
                pages.first(
                    where: {
                        $0.identifier.rawValue
                            == reference
                                .destination
                                .rawValue
                    }
                )
        else {
            throw
                SiteReferenceResolutionError
                    .destinationNotFound(
                        reference
                            .destination
                            .rawValue
                    )
        }

        return
            ResolvedReference(
                source:
                    resolvedSource.identifier,
                destination:
                    resolvedDestination.identifier,
                sourceRoute:
                    resolvedSource
                        .route
                        .siteRoute,
                destinationRoute:
                    resolvedDestination
                        .route
                        .siteRoute,
                style:
                    reference.style
            )
    }
}
