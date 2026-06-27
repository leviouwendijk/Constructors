import Path
import Primitives

public struct PageGraph<Page: PageGraphNode>: Sendable {
    public let roots: [Page]

    public init(
        roots: [Page]
    ) {
        self.roots = roots
    }

    public func resolved() throws -> [ResolvedPage<Page>] {
        var pages: [ResolvedPage<Page>] = []
        var identifiers: Set<String> = []
        var routes: Set<String> = []

        for root in roots {
            try append(
                root,
                ancestors: [],
                segments: [],
                pages: &pages,
                identifiers: &identifiers,
                routes: &routes
            )
        }

        return pages
    }

    public func navigation(
        in environment: BuildEnvironment
    ) throws -> NavigationStructure {
        let roots = try resolved()
            .filter { page in
                page.depth == 0 &&
                page.visibility.contains(environment)
            }
            .compactMap { page in
                navigationNode(
                    for: page.page,
                    ancestors: [],
                    environment: environment
                )
            }

        return NavigationStructure(
            roots: roots
        )
    }

    private func append(
        _ page: Page,
        ancestors: [Page],
        segments parentSegments: [PathSegment],
        pages: inout [ResolvedPage<Page>],
        identifiers: inout Set<String>,
        routes: inout Set<String>
    ) throws {
        let identifier = page.identifier.rawValue

        guard !identifiers.contains(identifier) else {
            throw PageGraphError.duplicateIdentifier(identifier)
        }

        identifiers.insert(identifier)

        if let slug = page.slug, slug.value.contains("/") {
            throw PageGraphError.slashBearingSlug(slug.value)
        }

        let nextSegments: [PathSegment]

        if let slug = page.slug {
            nextSegments = parentSegments + [
                PathSegment(
                    slug.value,
                    .directory
                )
            ]
        } else {
            nextSegments = parentSegments
        }

        let route = PageRoute(
            identifier: page.identifier,
            segments: nextSegments
        )

        guard !routes.contains(route.href) else {
            throw PageGraphError.duplicateRoute(route.href)
        }

        routes.insert(route.href)

        let resolvedPage = ResolvedPage(
            page: page,
            route: route,
            ancestors: ancestors
        )

        pages.append(resolvedPage)

        for child in page.children {
            try append(
                child,
                ancestors: ancestors + [page],
                segments: nextSegments,
                pages: &pages,
                identifiers: &identifiers,
                routes: &routes
            )
        }
    }

    private func navigationNode(
        for page: Page,
        ancestors: [Page],
        environment: BuildEnvironment
    ) -> NavigationNode? {
        guard page.visibility.contains(environment) else {
            return nil
        }

        let segments = (ancestors + [page])
            .compactMap(\.slug)
            .map { segment in
                PathSegment(
                    segment.value,
                    .directory
                )
            }

        let route = PageRoute(
            identifier: page.identifier,
            segments: segments
        )

        let children = page.children.compactMap { child in
            navigationNode(
                for: child,
                ancestors: ancestors + [page],
                environment: environment
            )
        }

        return NavigationNode(
            label: page.title,
            path: page.slug == nil && children.isEmpty ? nil : route.href,
            children: children
        )
    }
}
