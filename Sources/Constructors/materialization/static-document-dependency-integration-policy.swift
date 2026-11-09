public enum StaticJavaScriptDocumentPlacement:
    Sendable,
    Equatable
{
    case headEnd
    case bodyEnd
}

/// Policy for connecting already-packaged static dependencies to documents.
///
/// The public stylesheet reference is deliberately distinct from the physical
/// `StandardPath` owned by `StaticStylesheetArtifactPlan`. Static deployment
/// may later place an artifact beneath a different public base path or origin.
///
/// Inline and external scripts may also choose different structural placement
/// without changing the script values or their attributes.
public struct StaticDocumentDependencyIntegrationPolicy:
    Sendable,
    Equatable
{
    public let stylesheetHref:
        String

    public let inlineScriptPlacement:
        StaticJavaScriptDocumentPlacement

    public let externalScriptPlacement:
        StaticJavaScriptDocumentPlacement

    public init(
        stylesheetHref:
            String = "/assets/css/site.css",
        inlineScriptPlacement:
            StaticJavaScriptDocumentPlacement =
                .bodyEnd,
        externalScriptPlacement:
            StaticJavaScriptDocumentPlacement =
                .bodyEnd
    ) {
        self.stylesheetHref =
            stylesheetHref

        self.inlineScriptPlacement =
            inlineScriptPlacement

        self.externalScriptPlacement =
            externalScriptPlacement
    }
}
