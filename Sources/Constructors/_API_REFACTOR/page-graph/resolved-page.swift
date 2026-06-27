import Path
import Primitives

public struct ResolvedPage<Page: PageGraphNode>: Sendable {
    public let page: Page
    public let route: PageRoute<Page.PageIdentifier>
    public let ancestors: [Page]
    public let depth: Int

    public init(
        page: Page,
        route: PageRoute<Page.PageIdentifier>,
        ancestors: [Page]
    ) {
        self.page = page
        self.route = route
        self.ancestors = ancestors
        self.depth = ancestors.count
    }

    public var identifier: Page.PageIdentifier {
        page.identifier
    }

    public var title: String {
        page.title
    }

    public var visibility: Set<BuildEnvironment> {
        page.visibility
    }
}
