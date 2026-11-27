import Path
import Primitives

public enum SiteDeclarationError:
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

/// A declared page in the page graph: the bridge from `Site` to
/// Constructors' resolution and rendering.
public struct SitePageNode:
    PageGraphNode
{
    public let page: SitePage
    public let children: [SitePageNode]

    public var identifier: SitePageIdentifier {
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

public extension Site {
    /// The page tree, nested by path.
    static func pageTree() throws -> SitePageNode {
        var byPath: [[String]: SitePage] = [:]

        for page in pages {
            guard page.host == host else {
                throw SiteDeclarationError.foreignPage(host: host, page: page.pageKey.rawValue)
            }
            guard byPath[page.path] == nil else {
                throw SiteDeclarationError.duplicatePath(host: host, path: page.href)
            }
            byPath[page.path] = page
        }

        guard let root = byPath[[]] else {
            throw SiteDeclarationError.missingRoot(host: host)
        }

        for page in pages where !page.path.isEmpty {
            guard byPath[Array(page.path.dropLast())] != nil else {
                throw SiteDeclarationError.orphan(host: host, path: page.href)
            }
        }

        func node(_ page: SitePage) -> SitePageNode {
            SitePageNode(
                page: page,
                children: pages
                    .filter { $0.path.count == page.path.count + 1 && Array($0.path.dropLast()) == page.path }
                    .map(node)
            )
        }

        return node(root)
    }

    static func pageGraph() throws -> PageGraph<SitePageNode> {
        PageGraph(roots: [try pageTree()])
    }
}

public extension Site {
    /// Renders every page visible in `environment` with `body`.
    static func render(
        in environment: BuildEnvironment = .public,
        policy: SiteRenderingPolicy = .init(),
        body: (SitePage, RenderContext<SitePageNode>) throws -> PageRenderOutput
    ) throws -> SiteRenderResult<SitePageNode> {
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
        body: (SitePage, RenderContext<SitePageNode>) throws -> PageRenderOutput
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
