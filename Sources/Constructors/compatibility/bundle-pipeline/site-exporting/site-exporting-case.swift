import Path
import Primitives

@available(
    *,
    deprecated,
    message: """
    Legacy case-based export bridge. Prefer SiteDeclaring.declarations() with DocumentDeclaration, StyleDeclaration, and SnippetDeclaration.
    """
)
public protocol SiteExportingCase:
    CaseIterable,
    Hashable,
    Sendable,
    RawRepresentable,
    Identifiable
where RawValue == String, ID == String {
    var id: String { get }

    var path: StandardPath { get }
    var output: StandardPath { get }

    var visibility: Set<BuildEnvironment> { get }
    var metadata: TargetMetadata? { get }

    func bundle() -> RenderBundle
}

@available(
    *,
    deprecated,
    message: """
    Legacy case-based document bridge. Prefer SiteDeclaring.declarations() with DocumentDeclaration.
    """
)
public protocol SiteDocumentCase: SiteExportingCase {
    var navigation: NavigationSetting { get }
}

@available(
    *,
    deprecated,
    message: """
    Legacy case-based style bridge. Prefer SiteDeclaring.declarations() with StyleDeclaration.
    """
)
public protocol SiteStylesheetCase: SiteExportingCase {
    var pruneUnusedSelectors: Bool { get }
    var indentStep: Int { get }
}

@available(
    *,
    deprecated,
    message: """
    SiteSnippetMode is a temporary bridge. Prefer expressing snippet output directly through SnippetDeclaration + bundle export APIs.
    """
)
public enum SiteSnippetMode: Sendable, Equatable {
    case inline
    case external(cssPath: StandardPath)
    case fragment
}

public enum SiteSnippetSortingCategory: String, Sendable, Equatable, CaseIterable {
    case asset
    case document

    public var segment: PathSegment {
        PathSegment(rawValue)
    }
}

@available(
    *,
    deprecated,
    message: """
    Legacy case-based snippet bridge. Prefer SiteDeclaring.declarations() with SnippetDeclaration.
    """
)
public protocol SiteSnippetCase: SiteExportingCase {
    @available(
        *,
        deprecated,
        message: """
        Prefer expressing snippet output directly through SnippetDeclaration rather than a secondary mode enum.
        """
    )
    var mode: SiteSnippetMode { get }
}

public struct SiteSnippetRouting: Sendable, Equatable {
    public let namespace: StandardPath
    public let category: SiteSnippetSortingCategory?
    public let affix: PathSegmentAffix?

    public init(
        namespace: StandardPath = .init(["snippets"]),
        category: SiteSnippetSortingCategory? = nil,
        affix: PathSegmentAffix? = nil
    ) {
        self.namespace = namespace
        self.category = category
        self.affix = affix
    }

    public var prefix: StandardPath {
        var path = namespace

        if let category {
            path.appendingSegments([category.segment])
        }

        return path
    }

    public func resolve(
        _ leafOutput: StandardPath
    ) -> StandardPath {
        prefix
            .merged(appending: leafOutput)
            .affixedLastSegment(affix)
    }
}
