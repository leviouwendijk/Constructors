import Primitives

public struct PageRoute<
    Identifier:
        StringIdentifier
>:
    Sendable,
    Hashable
{
    public let identifier:
        Identifier

    /// Authoritative logical route.
    ///
    /// Filesystem directories and index-file paths are intentionally absent.
    public let siteRoute:
        SiteRoute

    public init(
        identifier:
            Identifier,
        siteRoute:
            SiteRoute
    ) {
        self.identifier =
            identifier

        self.siteRoute =
            siteRoute
    }

    /// Transitional URL serialization convenience.
    ///
    /// Semantic consumers should retain `siteRoute` wherever possible.
    public var href:
        String
    {
        siteRoute.href
    }
}
