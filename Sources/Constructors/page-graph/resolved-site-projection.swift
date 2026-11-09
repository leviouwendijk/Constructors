import Primitives

public extension ResolvedSite {
    /// Project this completely-resolved semantic site into one build
    /// environment.
    ///
    /// Page existence is determined first. Every declared relationship must
    /// then be projectable inside that exact page projection. A relationship
    /// cannot silently survive when either its source or destination does not
    /// exist in the selected semantic site.
    func project(
        in environment:
            BuildEnvironment
    ) throws -> SiteProjection<Page> {
        let pageProjection =
            pages
                .project(
                    in:
                        environment
                )

        let projectedReferences =
            try references
                .map { reference in
                    try pageProjection
                        .project(
                            reference
                        )
                }

        return
            SiteProjection(
                environment:
                    pageProjection
                        .environment,
                pages:
                    pageProjection
                        .pages,
                references:
                    projectedReferences
            )
    }
}
