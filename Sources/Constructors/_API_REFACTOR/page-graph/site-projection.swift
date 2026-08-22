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

    init(
        environment:
            BuildEnvironment,
        pages:
            [PageProjection<Page>]
    ) {
        self.environment =
            environment

        self.pages =
            pages
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
