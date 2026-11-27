import Path
import Primitives

public extension Site {
    enum DeclarationError:
        Error,
        Sendable,
        Equatable
    {
        case missingRoot(host: String)
        case duplicatePath(host: String, path: String)
        /// A page whose parent path has no page.
        case orphan(host: String, path: String)
        case foreignPage(host: String, page: String)
        case unknownSite(String)
        case unknownPage(String)
    }
}

public extension Site {
    /// A declared page in the page graph: the bridge from `Site.Declaring` to
    /// Constructors' resolution and rendering.
    struct PageNode:
        PageGraphNode
    {
        public let page: Site.Page
        public let children: [Site.PageNode]

        public var identifier: Site.PageIdentifier {
            page.identifier
        }

        public var slug: PathSegment? {
            page.path.last.map { PathSegment($0) }
        }

        public var title: String {
            page.title
        }

        public var visibility: Set<BuildEnvironment> {
            page.visibility
        }
    }
}

public extension Site.Declaring {
    /// The page tree, nested by path.
    static func pageTree() throws -> Site.PageNode {
        var byPath: [[String]: Site.Page] = [:]

        for page in pages {
            guard page.host == host else {
                throw Site.DeclarationError.foreignPage(host: host, page: page.pageKey.rawValue)
            }
            guard byPath[page.path] == nil else {
                throw Site.DeclarationError.duplicatePath(host: host, path: page.href)
            }
            byPath[page.path] = page
        }

        guard let root = byPath[[]] else {
            throw Site.DeclarationError.missingRoot(host: host)
        }

        for page in pages where !page.path.isEmpty {
            guard byPath[Array(page.path.dropLast())] != nil else {
                throw Site.DeclarationError.orphan(host: host, path: page.href)
            }
        }

        func node(_ page: Site.Page) -> Site.PageNode {
            Site.PageNode(
                page: page,
                children: pages
                    .filter { $0.path.count == page.path.count + 1 && Array($0.path.dropLast()) == page.path }
                    .map(node)
            )
        }

        return node(root)
    }

    static func pageGraph() throws -> PageGraph<Site.PageNode> {
        PageGraph(roots: [try pageTree()])
    }
}

public extension Site.Declaring {
    /// Renders every page visible in `environment` with `body`.
    static func render(
        in environment: BuildEnvironment = .public,
        policy: SiteRenderingPolicy = .init(),
        body: (Site.Page, RenderContext<Site.PageNode>) throws -> PageRenderOutput
    ) throws -> SiteRenderResult<Site.PageNode> {
        let projection = try pageGraph()
            .resolve()
            .project(in: environment)

        return try RenderContext(
            projection: projection,
            policy: policy
        )
        .renderSite { projected, context in
            try body(projected.page.page, context)
        }
    }

    /// The whole site as an `ArtifactTree`: render, materialize, plan.
    static func artifactTree(
        in environment: BuildEnvironment = .public,
        rendering: SiteRenderingPolicy = .init(),
        materialization: StaticSiteMaterializationPolicy = .init(),
        body: (Site.Page, RenderContext<Site.PageNode>) throws -> PageRenderOutput
    ) throws -> ArtifactTree {
        try StaticSiteMaterializer(policy: materialization)
            .prepare(
                try render(
                    in: environment,
                    policy: rendering,
                    body: body
                )
            )
            .tree
    }
}
