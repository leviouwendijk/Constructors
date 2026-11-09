/// The semantic declaration of one site before graph/reference resolution.
///
/// This value owns authoring-time site structure and relationships only.
/// Rendering state, HTTP state, filesystem roots, and materialization policy
/// remain caller concerns at later stages.
public struct DeclaredSite<
    Page:
        PageGraphNode
>:
    Sendable
{
    public let pages:
        PageGraph<Page>

    public let references:
        [SiteReferenceDeclaration<Page.PageIdentifier>]

    public init(
        pages:
            PageGraph<Page>,
        references:
            [SiteReferenceDeclaration<Page.PageIdentifier>] = []
    ) {
        self.pages =
            pages

        self.references =
            references
    }

    /// Resolve the complete semantic declaration.
    ///
    /// The page graph is resolved exactly once. Every declared site
    /// relationship is then resolved against that exact invariant-bearing
    /// `ResolvedPageGraph`.
    public func resolve()
        throws -> ResolvedSite<Page>
    {
        let resolvedPages =
            try pages
                .resolve()

        let resolvedReferences =
            try references
                .map { declaration in
                    try resolvedPages
                        .resolve(
                            declaration
                                .reference,
                            from:
                                declaration
                                    .source
                        )
                }

        return
            ResolvedSite(
                pages:
                    resolvedPages,
                references:
                    resolvedReferences
            )
    }
}
