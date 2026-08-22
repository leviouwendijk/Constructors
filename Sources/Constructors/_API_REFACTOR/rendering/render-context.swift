public struct RenderContext<
    Page:
        PageGraphNode
>:
    Sendable
{
    public let projection:
        SiteProjection<Page>

    public let policy:
        SiteRenderingPolicy

    public init(
        projection:
            SiteProjection<Page>,
        policy:
            SiteRenderingPolicy = .init()
    ) {
        self.projection =
            projection

        self.policy =
            policy
    }

    public func render(
        _ reference:
            ProjectedReference<Page.PageIdentifier>
    ) throws -> RenderedReference<Page.PageIdentifier> {
        RenderedReference(
            projected:
                reference,
            href:
                try policy
                    .href(
                        for:
                            reference
                    )
        )
    }
}
