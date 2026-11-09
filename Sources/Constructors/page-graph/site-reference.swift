import Primitives

/// Authoring-time relationship to another semantic site document.
///
/// This value deliberately knows the destination identity and requested
/// reference style, but does not yet contain an href, filesystem path, or
/// HTML representation.
public struct SiteReference<
    Identifier:
        StringIdentifier
>:
    Sendable,
    Equatable
{
    public let destination:
        Identifier

    public let style:
        SiteReferenceStyle

    public init(
        destination:
            Identifier,
        style:
            SiteReferenceStyle = .automatic
    ) {
        self.destination =
            destination

        self.style =
            style
    }
}

public extension SiteReference {
    static func to(
        _ destination:
            Identifier,
        style:
            SiteReferenceStyle = .automatic
    ) -> SiteReference {
        SiteReference(
            destination:
                destination,
            style:
                style
        )
    }
}
