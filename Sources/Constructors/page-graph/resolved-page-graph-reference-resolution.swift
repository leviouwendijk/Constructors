import Primitives

public extension ResolvedPageGraph {
    /// Resolve one authoring-time site reference inside this already-resolved
    /// semantic graph.
    ///
    /// Successful resolution proves:
    ///
    /// - the source identity exists in this resolved graph;
    /// - the destination identity exists in this resolved graph;
    /// - both logical routes are already known;
    /// - the authoring reference style remains semantic information.
    ///
    /// No projection, href, filesystem path, or HTML representation is
    /// produced here.
    func resolve(
        _ reference:
            SiteReference<Page.PageIdentifier>,
        from source:
            Page.PageIdentifier
    ) throws -> ResolvedReference<Page.PageIdentifier> {
        guard
            let resolvedSource =
                self[
                    source
                ]
        else {
            throw
                SiteReferenceResolutionError
                    .sourceNotFound(
                        source.rawValue
                    )
        }

        guard
            let resolvedDestination =
                self[
                    reference
                        .destination
                ]
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
                    resolvedSource
                        .identifier,
                destination:
                    resolvedDestination
                        .identifier,
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
