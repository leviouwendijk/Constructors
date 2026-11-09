import CSS
import JS

public enum SiteRenderResultError:
    Error,
    Sendable,
    Equatable
{
    case documentNotProjected(
        String
    )

    case documentRouteMismatch(
        identifier:
            String,
        projected:
            SiteRoute,
        rendered:
            SiteRoute
    )
}

/// Rich rendering result for one coherent site projection.
///
/// Documents remain tied to projected semantic pages and retain their domain
/// representations. Site-wide dependency state is derived from those
/// documents during initialization so it cannot drift independently.
///
/// Concrete generated resources intentionally remain outside this first result
/// spine until declaration/resolution/projection owns a real resource identity.
public struct SiteRenderResult<
    Page:
        PageGraphNode
>:
    Sendable
{
    public let projection:
        SiteProjection<Page>

    public let documents:
        [RenderedDocument<Page>]

    public let dependencies:
        RenderDependencies

    public init(
        projection:
            SiteProjection<Page>,
        documents:
            [RenderedDocument<Page>]
    ) throws {
        for document
            in documents
        {
            guard
                let projected =
                    projection[
                        document
                            .identifier
                    ]
            else {
                throw
                    SiteRenderResultError
                        .documentNotProjected(
                            document
                                .identifier
                                .rawValue
                        )
            }

            guard
                projected
                    .siteRoute
                    == document
                        .route
            else {
                throw
                    SiteRenderResultError
                        .documentRouteMismatch(
                            identifier:
                                document
                                    .identifier
                                    .rawValue,
                            projected:
                                projected
                                    .siteRoute,
                            rendered:
                                document
                                    .route
                        )
            }
        }

        let styles =
            try CSSContributions(
                documents
                    .flatMap { document in
                        document
                            .styles
                            .contributions
                    }
            )
            .resolve()

        let scripts =
            try JSContributions(
                documents
                    .flatMap { document in
                        document
                            .scripts
                            .contributions
                    }
            )
            .resolve()

        self.projection =
            projection

        self.documents =
            documents

        self.dependencies =
            RenderDependencies(
                styles:
                    styles,
                scripts:
                    scripts
            )
    }
}
