import Primitives

public struct PageGraph<
    Page:
        PageGraphNode
>:
    Sendable
{
    public let roots:
        [Page]

    public init(
        roots:
            [Page]
    ) {
        self.roots =
            roots
    }

    /// Resolve the declaration graph into coherent semantic graph state.
    ///
    /// Successful resolution returns a `ResolvedPageGraph` so callers cannot
    /// accidentally discard the collection-level invariant and then ask later
    /// stages to resolve the declaration graph again.
    public func resolve()
        throws -> ResolvedPageGraph<Page>
    {
        var pages:
            [ResolvedPage<Page>] =
                []

        var identifiers:
            Set<String> =
                []

        var routes:
            Set<SiteRoute> =
                []

        for root
            in roots
        {
            try append(
                root,
                ancestors:
                    [],
                parentRoute:
                    .root,
                pages:
                    &pages,
                identifiers:
                    &identifiers,
                routes:
                    &routes
            )
        }

        return
            ResolvedPageGraph(
                pages:
                    pages
            )
    }

    private func append(
        _ page:
            Page,
        ancestors:
            [Page],
        parentRoute:
            SiteRoute,
        pages:
            inout [ResolvedPage<Page>],
        identifiers:
            inout Set<String>,
        routes:
            inout Set<SiteRoute>
    ) throws {
        let identifier =
            page
                .identifier
                .rawValue

        guard
            !identifiers
                .contains(
                    identifier
                )
        else {
            throw
                PageGraphError
                    .duplicateIdentifier(
                        identifier
                    )
        }

        identifiers.insert(
            identifier
        )

        let nextRoute:
            SiteRoute

        if
            let slug =
                page.slug
        {
            guard
                !slug
                    .value
                    .contains(
                        "/"
                    )
            else {
                throw
                    PageGraphError
                        .slashBearingSlug(
                            slug.value
                        )
            }

            nextRoute =
                parentRoute
                    .appending(
                        SiteRoute
                            .Segment(
                                slug.value
                            )
                    )
        } else {
            nextRoute =
                parentRoute
        }

        let route =
            PageRoute(
                identifier:
                    page.identifier,
                siteRoute:
                    nextRoute
            )

        guard
            !routes
                .contains(
                    nextRoute
                )
        else {
            throw
                PageGraphError
                    .duplicateRoute(
                        nextRoute
                    )
        }

        routes.insert(
            nextRoute
        )

        pages
            .append(
                ResolvedPage(
                    page:
                        page,
                    route:
                        route,
                    ancestors:
                        ancestors
                )
            )

        for child
            in page.children
        {
            try append(
                child,
                ancestors:
                    ancestors
                    + [
                        page,
                    ],
                parentRoute:
                    nextRoute,
                pages:
                    &pages,
                identifiers:
                    &identifiers,
                routes:
                    &routes
            )
        }
    }
}
