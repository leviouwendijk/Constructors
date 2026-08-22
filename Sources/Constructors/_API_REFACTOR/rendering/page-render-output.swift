import CSS
import HTML
import JS

/// Rich output produced by a site-owned page renderer before dependency
/// identity is resolved for the resulting `RenderedDocument`.
///
/// The document remains a semantic `HTMLDocument`. CSS and JavaScript remain
/// identified unresolved contribution collections so composition may
/// truthfully contribute the same dependency more than once.
///
/// `RenderContext` establishes the stronger resolved dependency invariant when
/// it turns this value into a `RenderedDocument`.
public struct PageRenderOutput:
    Sendable
{
    public let document:
        HTMLDocument

    public let styles:
        CSSContributions

    public let scripts:
        JSContributions

    public init(
        document:
            HTMLDocument,
        styles:
            CSSContributions = CSSContributions(
                []
            ),
        scripts:
            JSContributions = JSContributions(
                []
            )
    ) {
        self.document =
            document

        self.styles =
            styles

        self.scripts =
            scripts
    }
}
