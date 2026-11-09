import Primitives

public enum SiteProjectionError:
    Error,
    Sendable,
    Equatable
{
    case sourceNotProjected(
        String
    )

    case destinationNotProjected(
        String
    )
}

/// The semantic site that exists for one build environment.
///
/// Resolution has already established coherent page, route, hierarchy, and
/// reference identity. Projection decides only which resolved semantic objects
/// exist in this environment.
public struct SiteProjection<
    Page:
        PageGraphNode
>:
    Sendable
{
    public let environment:
        BuildEnvironment

    public let pages:
        [PageProjection<Page>]

    /// Semantic relationships that were already resolved and have now also
    /// been proven to exist in this projection.
    public let references:
        [ProjectedReference<Page.PageIdentifier>]

    init(
        environment:
            BuildEnvironment,
        pages:
            [PageProjection<Page>],
        references:
            [ProjectedReference<Page.PageIdentifier>] = []
    ) {
        self.environment =
            environment

        self.pages =
            pages

        self.references =
            references
    }

    public subscript(
        _ identifier:
            Page.PageIdentifier
    ) -> PageProjection<Page>? {
        pages
            .first { page in
                page
                    .identifier
                    .rawValue
                    == identifier
                        .rawValue
            }
    }

    /// Find the projected page that owns one exact logical route.
    ///
    /// The route has already crossed its parsing/resolution boundary. Lookup
    /// therefore compares structural `SiteRoute` identity and never reparses or
    /// compares serialized `href` text.
    public subscript(
        route route:
            SiteRoute
    ) -> PageProjection<Page>? {
        pages
            .first { page in
                page
                    .siteRoute
                    == route
            }
    }

    /// Find one relationship that was declared before Resolution and survived
    /// Projection.
    ///
    /// This lookup does not resolve or project anything. Source identity,
    /// destination identity, and reference style must match an existing
    /// `ProjectedReference` exactly.
    public func reference(
        _ reference:
            SiteReference<Page.PageIdentifier>,
        from source:
            Page.PageIdentifier
    ) -> ProjectedReference<Page.PageIdentifier>? {
        references
            .first { projected in
                projected
                    .source
                    .rawValue
                    == source
                        .rawValue
                && projected
                    .destination
                    .rawValue
                    == reference
                        .destination
                        .rawValue
                && projected
                    .style
                    == reference
                        .style
            }
    }

    /// Strengthen one already-resolved semantic relationship with projected
    /// existence.
    ///
    /// This method deliberately accepts `ResolvedReference`, not
    /// `SiteReference`: global relationship resolution belongs to the
    /// Resolution stage and is never repeated here.
    public func project(
        _ resolved:
            ResolvedReference<Page.PageIdentifier>
    ) throws -> ProjectedReference<Page.PageIdentifier> {
        guard
            self[
                resolved
                    .source
            ]
                != nil
        else {
            throw
                SiteProjectionError
                    .sourceNotProjected(
                        resolved
                            .source
                            .rawValue
                    )
        }

        guard
            self[
                resolved
                    .destination
            ]
                != nil
        else {
            throw
                SiteProjectionError
                    .destinationNotProjected(
                        resolved
                            .destination
                            .rawValue
                    )
        }

        return
            ProjectedReference(
                resolved:
                    resolved
            )
    }
}
