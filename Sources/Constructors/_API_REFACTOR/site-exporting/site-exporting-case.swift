import Path
import Primitives

public protocol SiteExportingCase:
    CaseIterable,
    Hashable,
    Sendable,
    RawRepresentable,
    Identifiable
where RawValue == String, ID == String {
    var id: String { get }

    /// Final emitted output path for this declaration.
    /// For snippets, this should be the fully resolved emitted path.
    var output: StandardPath { get }

    var visibility: Set<BuildEnvironment> { get }
    var metadata: TargetMetadata? { get }

    func bundle() -> RenderBundle
}

public protocol SiteDocumentCase: SiteExportingCase {
    var navigation: NavigationSetting { get }
}

public protocol SiteStylesheetCase: SiteExportingCase {
    var pruneUnusedSelectors: Bool { get }
    var indentStep: Int { get }
}

@available(
    *,
    deprecated,
    message: """
    SiteSnippetMode is a temporary bridge. Prefer expressing snippet output directly through bundle export APIs, e.g. bundle().export.document.html.evaluate(...) or bundle().export.fragment.html.evaluate(...).
    """
)
public enum SiteSnippetMode: Sendable, Equatable {
    case inline
    case external(cssPath: GenericPath)
    case fragment
}

public protocol SiteSnippetCase: SiteExportingCase {
    @available(
        *,
        deprecated,
        message: """
        Prefer expressing snippet output directly through bundle export APIs rather than a secondary mode enum.
        """
    )
    var mode: SiteSnippetMode { get }
    var suffix: String { get }
}
