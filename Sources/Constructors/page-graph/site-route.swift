public struct SiteRoute:
    Sendable,
    Hashable,
    CustomStringConvertible
{
    /// One logical URL-route segment.
    ///
    /// This deliberately carries no filesystem kind such as `.directory`
    /// or `.file`. Those concepts belong to later materialization.
    public struct Segment:
        Sendable,
        Hashable,
        CustomStringConvertible,
        ExpressibleByStringLiteral
    {
        public let rawValue:
            String

        public init(
            _ rawValue:
                String
        ) {
            self.rawValue =
                rawValue
        }

        public init(
            stringLiteral value:
                String
        ) {
            self.init(
                value
            )
        }

        public var description:
            String
        {
            rawValue
        }
    }

    public static let root =
        SiteRoute(
            resolvedSegments:
                []
        )

    public let segments:
        [Segment]

    /// Direct construction from resolved segment arrays remains inside
    /// Constructors graph resolution. External transport adapters should enter
    /// through `SiteRoute(parsingPath:)` rather than manufacturing resolved
    /// segment-array state.
    init(
        resolvedSegments:
            [Segment]
    ) {
        self.segments =
            resolvedSegments
    }

    func appending(
        _ segment:
            Segment
    ) -> SiteRoute {
        SiteRoute(
            resolvedSegments:
                segments
                + [
                    segment,
                ]
        )
    }

    /// URL serialization of this logical route.
    ///
    /// This is a derived representation, not the route's authoritative
    /// identity.
    public var href:
        String
    {
        guard
            !segments.isEmpty
        else {
            return "/"
        }

        return
            "/"
            + segments
                .map(
                    \.rawValue
                )
                .joined(
                    separator:
                        "/"
                )
            + "/"
    }

    public var description:
        String
    {
        href
    }
}
