import Path
import Primitives

@available(
    *,
    deprecated,
    message: """
    Legacy case-based export bridge defaults. Prefer SiteDeclaring.declarations() with DocumentDeclaration, StyleDeclaration, and SnippetDeclaration.
    """
)
public extension SiteExportingCase {
    var id: String {
        rawValue
    }

    @available(*, deprecated, message: "use id")
    var key: String {
        id
    }

    var visibility: Set<BuildEnvironment> {
        [.local, .test, .public]
    }

    var metadata: TargetMetadata? {
        nil
    }

    var output: StandardPath {
        path
    }
}

@available(
    *,
    deprecated,
    message: """
    Legacy case-based document bridge defaults. Prefer SiteDeclaring.declarations() with DocumentDeclaration.
    """
)
public extension SiteDocumentCase {
    var navigation: NavigationSetting {
        .none
    }

    var metadata: TargetMetadata? {
        .default
    }
}

@available(
    *,
    deprecated,
    message: """
    Legacy case-based style bridge defaults. Prefer SiteDeclaring.declarations() with StyleDeclaration.
    """
)
public extension SiteStylesheetCase {
    var pruneUnusedSelectors: Bool {
        true
    }

    var indentStep: Int {
        4
    }
}

@available(
    *,
    deprecated,
    message: """
    Legacy case-based snippet bridge defaults. Prefer SiteDeclaring.declarations() with SnippetDeclaration.
    """
)
public extension SiteSnippetCase {
    var output: StandardPath {
        routing.resolve(path)
    }

    var routing: SiteSnippetRouting {
        .init()
    }

    var metadata: TargetMetadata? {
        .blocked
    }
}
