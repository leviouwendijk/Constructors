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

    public func resolved()
        throws -> [ResolvedPage<Page>]
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

        return pages
    }

    public func navigation(
        in environment:
            BuildEnvironment
    ) throws -> NavigationStructure {
        let roots =
            try resolved()
                .filter { page in
                    page.depth == 0
                    && page
                        .visibility
                        .contains(
                            environment
                        )
                }
                .compactMap { page in
                    navigationNode(
                        for:
                            page.page,
                        ancestors:
                            [],
                        environment:
                            environment
                    )
                }

        return
            NavigationStructure(
                roots:
                    roots
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

        let resolvedPage =
            ResolvedPage(
                page:
                    page,
                route:
                    route,
                ancestors:
                    ancestors
            )

        pages.append(
            resolvedPage
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

    private func navigationNode(
        for page:
            Page,
        ancestors:
            [Page],
        environment:
            BuildEnvironment
    ) -> NavigationNode? {
        guard
            page
                .visibility
                .contains(
                    environment
                )
        else {
            return nil
        }

        let siteRoute =
            (
                ancestors
                + [
                    page,
                ]
            )
            .compactMap(
                \.slug
            )
            .reduce(
                SiteRoute.root
            ) { route, slug in
                route
                    .appending(
                        SiteRoute
                            .Segment(
                                slug.value
                            )
                    )
            }

        let route =
            PageRoute(
                identifier:
                    page.identifier,
                siteRoute:
                    siteRoute
            )

        let children =
            page
                .children
                .compactMap { child in
                    navigationNode(
                        for:
                            child,
                        ancestors:
                            ancestors
                            + [
                                page,
                            ],
                        environment:
                            environment
                    )
                }

        return
            NavigationNode(
                label:
                    page.title,
                path:
                    page.slug == nil
                    && children.isEmpty
                        ? nil
                        : route.href,
                children:
                    children
            )
    }
}
