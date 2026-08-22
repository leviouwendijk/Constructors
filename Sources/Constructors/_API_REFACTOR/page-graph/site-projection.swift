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
/// Resolution has already established coherent page and route identity.
/// Projection only decides which of those resolved semantic objects exist.
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

    /// Resolve a relationship inside this projection.
    ///
    /// A globally valid page may still be absent here because projection has
    /// excluded it for this build environment.
    public func resolve(
        _ reference:
            SiteReference<Page.PageIdentifier>,
        from source:
            Page.PageIdentifier
    ) throws -> ProjectedReference<Page.PageIdentifier> {
        guard
            let projectedSource =
                self[
                    source
                ]
        else {
            throw
                SiteProjectionError
                    .sourceNotProjected(
                        source.rawValue
                    )
        }

        guard
            let projectedDestination =
                self[
                    reference.destination
                ]
        else {
            throw
                SiteProjectionError
                    .destinationNotProjected(
                        reference
                            .destination
                            .rawValue
                    )
        }

        return
            ProjectedReference(
                source:
                    projectedSource
                        .identifier,
                destination:
                    projectedDestination
                        .identifier,
                sourceRoute:
                    projectedSource
                        .siteRoute,
                destinationRoute:
                    projectedDestination
                        .siteRoute,
                style:
                    reference.style
            )
    }
}
