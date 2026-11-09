import Primitives

/// A resolved semantic reference whose source and destination have additionally
/// been proven to exist in one site projection.
///
/// Projection retains the exact `ResolvedReference` supplied by the Resolution
/// stage. It adds projected-existence proof without reconstructing semantic
/// identity, logical routes, or reference style.
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
        resolved:
            ResolvedReference<Identifier>
    ) {
        self.resolved =
            resolved
    }
}
