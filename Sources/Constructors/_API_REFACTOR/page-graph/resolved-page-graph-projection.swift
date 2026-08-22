import Primitives

public extension ResolvedPageGraph {
    /// Project this coherent semantic graph into one build environment.
    ///
    /// A resolved page exists in the projection only when:
    ///
    /// - the page itself is visible in the environment; and
    /// - every resolved ancestor is visible in the environment.
    ///
    /// Projection does not perform graph resolution or reconstruct routes.
    func project(
        in environment:
            BuildEnvironment
    ) -> SiteProjection<Page> {
        let pages =
            pages
                .filter { page in
                    page
                        .visibility
                        .contains(
                            environment
                        )
                    && page
                        .ancestors
                        .allSatisfy { ancestor in
                            ancestor
                                .visibility
                                .contains(
                                    environment
                                )
                        }
                }
                .map { page in
                    PageProjection(
                        resolvedPage:
                            page
                    )
                }

        return
            SiteProjection(
                environment:
                    environment,
                pages:
                    pages
            )
    }
}
