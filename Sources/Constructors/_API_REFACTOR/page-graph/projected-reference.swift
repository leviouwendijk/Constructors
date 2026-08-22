import Primitives

/// A resolved semantic reference whose source and destination have additionally
/// been proven to exist in one site projection.
///
/// The contained `ResolvedReference` preserves the stronger invariant already
/// established by semantic resolution. Projection adds another invariant
/// without lowering either identity or logical route to rendered text.
public struct ProjectedReference<
    Identifier:
        StringIdentifier
>:
    Sendable,
    Equatable
{
    public let resolved:
        ResolvedReference<Identifier>

    public var source:
        Identifier
    {
        resolved.source
    }

    public var destination:
        Identifier
    {
        resolved.destination
    }

    public var sourceRoute:
        SiteRoute
    {
        resolved.sourceRoute
    }

    public var destinationRoute:
        SiteRoute
    {
        resolved.destinationRoute
    }

    public var style:
        SiteReferenceStyle
    {
        resolved.style
    }

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
        self.resolved =
            ResolvedReference(
                source:
                    source,
                destination:
                    destination,
                sourceRoute:
                    sourceRoute,
                destinationRoute:
                    destinationRoute,
                style:
                    style
            )
    }
}
