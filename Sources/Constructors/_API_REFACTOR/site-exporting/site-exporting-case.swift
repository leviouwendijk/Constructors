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

    var path: StandardPath { get }
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

public protocol SiteSnippetCase: SiteExportingCase {
    @available(
        *,
        deprecated,
        message: """
        Prefer expressing snippet output directly through bundle export APIs rather than a secondary mode enum.
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
