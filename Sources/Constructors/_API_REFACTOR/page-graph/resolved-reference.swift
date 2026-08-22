import Primitives

/// A semantic site reference whose source and destination have both been
/// proven to exist in the resolved page graph.
///
/// Routes remain logical `SiteRoute` values. Rendering and materialization
/// are responsible for any eventual href or output-path representation.
public struct ResolvedReference<
    Identifier:
        StringIdentifier
>:
    Sendable,
    Equatable
{
    public let source:
        Identifier

    public let destination:
        Identifier

    public let sourceRoute:
        SiteRoute

    public let destinationRoute:
        SiteRoute

    public let style:
        SiteReferenceStyle

    init(
        source:
            Identifier,
        destination:
            Identifier,
        sourceRoute:
            SiteRoute,
        destinationRoute:
            SiteRoute,
        style:
            SiteReferenceStyle
    ) {
        self.source =
            source

        self.destination =
            destination

        self.sourceRoute =
            sourceRoute

        self.destinationRoute =
            destinationRoute

        self.style =
            style
    }
}
