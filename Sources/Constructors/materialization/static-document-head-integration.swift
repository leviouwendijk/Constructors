import DSL
import Foundation
import HTML

extension StaticDocumentDependencyIntegrator {
    /// The site head plus the page's overrides as nodes at the start of the
    /// head; `lang` on `<html>`. A `<title>` the page wrote itself is kept.
    func integrateHead(
        _ site: SiteHead,
        page: DocumentHead,
        route: SiteRoute,
        packaging: StaticDependencyPackaging,
        into document: inout HTMLDocument
    ) throws {
        func href(_ key: StructuredContent.AssetKey) throws -> String {
            guard let entry = packaging.assets.first(where: { $0.key == key }) else {
                throw ArtifactTreeError.unresolvedLink(.asset(key))
            }
            return entry.path.rendered(asRootPath: true)
        }

        func absolute(_ path: String) -> String? {
            site.canonicalBase.map {
                $0.absoluteString.trimmingSuffix("/") + path
            }
        }

        let pageTitle = page.title ?? site.siteName
        let title: String
        if let separator = site.titleSeparator, pageTitle != site.siteName {
            title = pageTitle + separator + site.siteName
        } else {
            title = pageTitle
        }

        let description = page.description ?? site.description
        let canonical = absolute(route.href)
        let image = try (page.image ?? site.image).map { try href($0) }

        var nodes: HTMLFragment = []

        let hasTitle = document.head.contains {
            ($0 as? HTMLElement)?.tag == "title"
        }
        if !hasTitle {
            nodes.append(HTML.title(title))
        }

        if let description {
            nodes.append(HTML.meta(["name": "description", "content": description]))
        }

        if page.noindex {
            nodes.append(HTML.meta(["name": "robots", "content": "noindex"]))
        }

        if let canonical {
            nodes.append(HTMLElement("link", attrs: ["rel": "canonical", "href": canonical], children: []))
        }

        if site.openGraph {
            nodes.append(HTML.meta(["property": "og:type", "content": "website"]))
            nodes.append(HTML.meta(["property": "og:site_name", "content": site.siteName]))
            nodes.append(HTML.meta(["property": "og:title", "content": pageTitle]))
            if let description {
                nodes.append(HTML.meta(["property": "og:description", "content": description]))
            }
            if let canonical {
                nodes.append(HTML.meta(["property": "og:url", "content": canonical]))
            }
            if let image, let url = absolute(image) {
                nodes.append(HTML.meta(["property": "og:image", "content": url]))
            }
        }

        if let icon = site.icon {
            nodes.append(HTMLElement("link", attrs: ["rel": "icon", "href": try href(icon)], children: []))
        }

        if let touch = site.appleTouchIcon {
            nodes.append(HTMLElement("link", attrs: ["rel": "apple-touch-icon", "href": try href(touch)], children: []))
        }

        if let manifest = site.manifest {
            nodes.append(HTMLElement("link", attrs: ["rel": "manifest", "href": try href(manifest)], children: []))
        }

        if let color = site.themeColor {
            nodes.append(HTML.meta(["name": "theme-color", "content": color.hex]))
        }

        document.head = nodes + document.head

        if let language = site.language {
            document.attributes.html.merge(["lang": language])
        }
    }
}

private extension String {
    func trimmingSuffix(_ suffix: String) -> String {
        hasSuffix(suffix) ? String(dropLast(suffix.count)) : self
    }
}
