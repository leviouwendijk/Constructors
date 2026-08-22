import Primitives

/// A page graph whose semantic identities, hierarchy, and logical routes have
/// been successfully resolved.
///
/// Construction is intentionally internal to `PageGraph.resolve()`. Receiving
/// this value proves that:
///
/// - every page identifier is unique;
/// - every logical `SiteRoute` is unique;
/// - every page slug is valid for graph route construction;
/// - every `ResolvedPage` carries its resolved route and ancestry.
///
/// Projection and semantic-reference resolution operate from this stronger
/// value rather than resolving the declaration graph again.
public struct ResolvedPageGraph<
    Page:
        PageGraphNode
>:
    Sendable
{
    public let pages:
        [ResolvedPage<Page>]

    init(
        pages:
            [ResolvedPage<Page>]
    ) {
        self.pages =
            pages
    }

    public subscript(
        _ identifier:
            Page.PageIdentifier
    ) -> ResolvedPage<Page>? {
        pages
            .first { page in
                page
                    .identifier
                    .rawValue
                    == identifier
                        .rawValue
            }
    }
}
