import CSS
import HTML

/// Terminal textual serialization policy for an already-integrated static site.
///
/// Nothing selected here changes page existence, route identity, dependency
/// identity, packaging, or document dependency placement.
///
/// The only responsibility is converting final HTML/CSS domain values into
/// their textual representations.
public struct StaticSerializationPolicy:
    Sendable
{
    public let html:
        HTMLRenderOptions

    public let stylesheet:
        CSSRenderOptions

    public init(
        html:
            HTMLRenderOptions =
                .Defaults
                .pretty(),
        stylesheet:
            CSSRenderOptions =
                CSSRenderOptions(
                    ensureTrailingNewline:
                        true
                )
    ) {
        self.html =
            html

        self.stylesheet =
            stylesheet
    }
}
