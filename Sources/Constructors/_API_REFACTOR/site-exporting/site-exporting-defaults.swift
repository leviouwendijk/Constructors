import Path
import Primitives

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

public extension SiteDocumentCase {
    var navigation: NavigationSetting {
        .none
    }

    var metadata: TargetMetadata? {
        .default
    }
}

public extension SiteStylesheetCase {
    var pruneUnusedSelectors: Bool {
        true
    }

    var indentStep: Int {
        4
    }
}

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
