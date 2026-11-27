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

    public let inlineScriptPlacement:
        StaticJavaScriptDocumentPlacement

    public let externalScriptPlacement:
        StaticJavaScriptDocumentPlacement

    public init(
        inlineScriptPlacement:
            StaticJavaScriptDocumentPlacement =
                .bodyEnd,
        externalScriptPlacement:
            StaticJavaScriptDocumentPlacement =
                .bodyEnd
    ) {

        self.inlineScriptPlacement =
            inlineScriptPlacement

        self.externalScriptPlacement =
            externalScriptPlacement
    }
}
