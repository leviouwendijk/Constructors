public extension SiteProjection {
    /// Derive navigation from the semantic pages that actually exist in this
    /// projection.
    ///
    /// Visibility is not evaluated here and logical routes are not rebuilt.
    /// Both decisions were already established by Resolution + Projection.
    func navigation(
        sortOrder:
            NavigationSortOrder = .insertion
    ) -> NavigationStructure {
        let roots =
            sorted(
                pages
                    .filter { page in
                        page.depth
                            == 0
                    }
                    .map { page in
                        navigationNode(
                            for:
                                page,
                            sortOrder:
                                sortOrder
                        )
                    },
                by:
                    sortOrder
            )

        return
            NavigationStructure(
                roots:
                    roots
            )
    }

    private func navigationNode(
        for page:
            PageProjection<Page>,
        sortOrder:
            NavigationSortOrder
    ) -> NavigationNode {
        let children =
            sorted(
                directChildren(
                    of:
                        page
                )
                .map { child in
                    navigationNode(
                        for:
                            child,
                        sortOrder:
                            sortOrder
                    )
                },
                by:
                    sortOrder
            )

        return
            NavigationNode(
                label:
                    page.title,
                path:
                    page
                        .page
                        .slug
                        == nil
                    && children.isEmpty
                        ? nil
                        : page
                            .siteRoute
                            .href,
                children:
                    children
            )
    }

    private func directChildren(
        of parent:
            PageProjection<Page>
    ) -> [PageProjection<Page>] {
        pages
            .filter { candidate in
                guard
                    candidate.depth
                        == parent.depth + 1,
                    let resolvedParent =
                        candidate
                            .resolvedPage
                            .ancestors
                            .last
                else {
                    return
                        false
                }

                return
                    resolvedParent
                        .identifier
                        .rawValue
                    == parent
                        .identifier
                        .rawValue
            }
    }

    private func sorted(
        _ nodes:
            [NavigationNode],
        by order:
            NavigationSortOrder
    ) -> [NavigationNode] {
        switch order {
        case .insertion:
            return
                nodes

        case .alphabetical:
            return
                nodes
                    .sorted { lhs, rhs in
                        lhs.label
                            < rhs.label
                    }
        }
    }
}
