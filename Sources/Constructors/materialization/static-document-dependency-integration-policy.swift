public enum StaticJavaScriptDocumentPlacement:
    Sendable,
    Equatable
{
    case headEnd
    case bodyEnd
}

/// Policy for connecting already-packaged static dependencies to documents.
///
/// The stylesheet `href` is derived from the stylesheet's planned path (W2),
/// so the two can't disagree. A different public base or origin belongs to
/// the path profile, not to a second string here.
///
/// Inline and external scripts may also choose different structural placement
/// without changing the script values or their attributes.
public struct StaticDocumentDependencyIntegrationPolicy:
    Sendable,
    Equatable
{

    /// The site's shared head; nil leaves each document's head as written.
    public let head:
        SiteHead?

    public let inlineScriptPlacement:
        StaticJavaScriptDocumentPlacement

    public let externalScriptPlacement:
        StaticJavaScriptDocumentPlacement

    public init(
        head:
            SiteHead? = nil,
        inlineScriptPlacement:
            StaticJavaScriptDocumentPlacement =
                .bodyEnd,
        externalScriptPlacement:
            StaticJavaScriptDocumentPlacement =
                .bodyEnd
    ) {

        self.head =
            head

        self.inlineScriptPlacement =
            inlineScriptPlacement

        self.externalScriptPlacement =
            externalScriptPlacement
    }
}
