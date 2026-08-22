import HTML
import Path

/// Static delivery policy for rendered HTML documents.
///
/// A `SiteRoute` remains the authoritative logical web route. This policy is
/// the first layer allowed to derive a concrete filesystem-oriented output
/// path from that route.
///
/// HTML rendering options are also materialization input because textual
/// serialization is terminal with respect to the retained `HTMLDocument`.
public struct StaticDocumentMaterializationPolicy:
    Sendable
{
    /// Basename used beneath every logical document route.
    ///
    /// The HTML file type is supplied separately by `StandardPath`, so the
    /// default is `index`, not `index.html`.
    public let indexBasename:
        String

    /// Terminal HTML serialization policy.
    public let html:
        HTMLRenderOptions

    public init(
        indexBasename:
            String = "index",
        html:
            HTMLRenderOptions =
                .Defaults
                .pretty()
    ) {
        self.indexBasename =
            indexBasename

        self.html =
            html
    }

    /// Derive the concrete static HTML output for a logical site route.
    ///
    /// Examples:
    ///
    ///     /           -> index.html
    ///     /contact/   -> contact/index.html
    ///
    /// No directory is created and no file is written here.
    public func documentOutput(
        for route:
            SiteRoute
    ) -> StandardPath {
        StandardPath(
            route
                .segments
                .map(
                    \.rawValue
                )
                + [
                    indexBasename,
                ],
            filetype:
                .text(
                    .html
                )
        )
    }
}
