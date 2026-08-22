import Path

/// Static output-identity policy for rendered HTML documents.
///
/// A `SiteRoute` remains the authoritative logical web route. This is the
/// first layer allowed to derive a concrete filesystem-oriented output path
/// from that route.
///
/// The document itself remains `HTMLDocument`. Terminal serialization occurs
/// only after materialization has structurally integrated packaged document
/// dependencies.
public struct StaticDocumentMaterializationPolicy:
    Sendable
{
    /// Basename used beneath every logical document route.
    ///
    /// The HTML file type is supplied separately by `StandardPath`, so the
    /// default is `index`, not `index.html`.
    public let indexBasename:
        String

    public init(
        indexBasename:
            String = "index"
    ) {
        self.indexBasename =
            indexBasename
    }

    /// Derive the concrete static HTML output for a logical site route.
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
