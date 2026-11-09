public struct PageProjection<
    Page:
        PageGraphNode
>:
    Sendable
{
    /// The resolved semantic page from which this projected page originates.
    ///
    /// Projection does not rebuild route or page identity. It decides whether
    /// that already-resolved semantic page exists in a particular build.
    public let resolvedPage:
        ResolvedPage<Page>

    init(
        resolvedPage:
            ResolvedPage<Page>
    ) {
        self.resolvedPage =
            resolvedPage
    }

    public var page:
        Page
    {
        resolvedPage.page
    }

    public var identifier:
        Page.PageIdentifier
    {
        resolvedPage.identifier
    }

    public var siteRoute:
        SiteRoute
    {
        resolvedPage
            .route
            .siteRoute
    }

    public var title:
        String
    {
        resolvedPage.title
    }

    public var depth:
        Int
    {
        resolvedPage.depth
    }
}
