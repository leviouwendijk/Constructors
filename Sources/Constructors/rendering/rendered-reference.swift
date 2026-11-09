import Primitives

/// HTML-facing reference representation produced at the rendering boundary.
///
/// The rendered href is available without discarding the projected semantic
/// relationship that produced it.
public struct RenderedReference<
    Identifier:
        StringIdentifier
>:
    Sendable,
    Equatable
{
    public let projected:
        ProjectedReference<Identifier>

    public let href:
        String

    init(
        projected:
            ProjectedReference<Identifier>,
        href:
            String
    ) {
        self.projected =
            projected

        self.href =
            href
    }
}
