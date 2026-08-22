import Primitives

public extension PageGraph {
    /// Project the fully resolved page graph into one build environment.
    ///
    /// A page exists in the projection only when:
    ///
    /// - the page itself is visible in the environment; and
    /// - every ancestor is visible in the environment.
    ///
    /// The second condition preserves hierarchical existence. A child cannot
    /// escape an excluded parent merely because its own visibility includes
    /// the environment.
    func project(
        in environment:
            BuildEnvironment
    ) throws -> SiteProjection<Page> {
        let pages =
            try resolved()
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
