/// A semantic site whose page graph and declared relationships have both been
/// successfully resolved.
///
/// Receiving this value proves that:
///
/// - the contained `ResolvedPageGraph` is coherent;
/// - every declared relationship has a valid source page;
/// - every declared relationship has a valid destination page;
/// - every relationship retains resolved logical route identity;
/// - no environment-specific existence decision has occurred yet.
public struct ResolvedSite<
    Page:
        PageGraphNode
>:
    Sendable
{
    public let pages:
        ResolvedPageGraph<Page>

    public let references:
        [ResolvedReference<Page.PageIdentifier>]

    init(
        pages:
            ResolvedPageGraph<Page>,
        references:
            [ResolvedReference<Page.PageIdentifier>]
    ) {
        self.pages =
            pages

        self.references =
            references
    }
}
