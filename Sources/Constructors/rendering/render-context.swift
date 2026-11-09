public enum RenderContextReferenceError:
    Error,
    Sendable,
    Equatable
{
    case referenceNotProjected(
        source:
            String,
        destination:
            String
    )
}

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

    /// Lower a relationship whose Resolution and Projection invariants have
    /// already been established.
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

    /// Render one authoring-time semantic reference only when the complete
    /// site lifecycle already declared, resolved, and projected that exact
    /// relationship.
    ///
    /// This is a lookup + lowering convenience. It deliberately does not call
    /// `ResolvedPageGraph.resolve` or `SiteProjection.project`.
    public func render(
        _ reference:
            SiteReference<Page.PageIdentifier>,
        from source:
            Page.PageIdentifier
    ) throws -> RenderedReference<Page.PageIdentifier> {
        guard
            let projected =
                projection
                    .reference(
                        reference,
                        from:
                            source
                    )
        else {
            throw
                RenderContextReferenceError
                    .referenceNotProjected(
                        source:
                            source
                                .rawValue,
                        destination:
                            reference
                                .destination
                                .rawValue
                    )
        }

        return
            try render(
                projected
            )
    }
}
