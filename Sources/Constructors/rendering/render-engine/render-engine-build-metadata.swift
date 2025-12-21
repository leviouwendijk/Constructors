import Foundation

extension RenderEngine {
    public func buildMetadataFiles() throws {
        // Always write robots.txt (especially important for test builds).
        let robots = try renderRobotsTxt()
        let robotsURL = context.baseURL.appendingPathComponent("robots.txt")
        try context.env.write(content: robots, to: robotsURL)

        // // Only publish sitemap.xml for public builds.
        // guard context.env == .public else {
        //     return
        // }

        let sitemap = try renderSitemapXml()
        let sitemapURL = context.baseURL.appendingPathComponent("sitemap.xml")
        try context.env.write(content: sitemap, to: sitemapURL)
    }
}

private extension RenderEngine {
    func renderRobotsTxt() throws -> String {
        // // Safer default: never allow indexing on non-public distributions.
        // if context.env != .public {
        //     return """
        //     User-agent: *
        //     Disallow: /

        //     """
        // }

        let pages = try context.site_object.keyedPages()
        let snippets = try context.site_object.keyedSnippets()

        var disallow: [String] = []

        for key in pages.keys.sorted() {
            guard let t = pages[key] else { continue }
            // guard t.visibility.contains(context.env) else { continue }
            guard t.visibility.contains(.public) else { continue }

            if t.metadata.robots == .disallow {
                disallow.append(t.output.rendered(asRootPath: true))
            }
        }

        for key in snippets.keys.sorted() {
            guard let t = snippets[key] else { continue }
            // guard t.visibility.contains(context.env) else { continue }
            guard t.visibility.contains(.public) else { continue }

            if t.metadata.robots == .disallow {
                disallow.append(t.output.rendered(asRootPath: true))
            }
        }

        disallow = Array(Set(disallow)).sorted()

        var out = "User-agent: *\n"
        if disallow.isEmpty {
            out += "Allow: /\n"
        } else {
            for p in disallow {
                out += "Disallow: \(p)\n"
            }
        }

        // Point crawlers to the sitemap we generate.
        let sitemapURL = context.site.root_address() + "sitemap.xml"
        out += "\nSitemap: \(sitemapURL)\n\n"

        return out
    }
}

private extension RenderEngine {
    func renderSitemapXml() throws -> String {
        let pages = try context.site_object.keyedPages()
        let snippets = try context.site_object.keyedSnippets()

        // Collect canonical URLs for *visible* + *indexable* targets.
        var locs: [String] = []

        for key in pages.keys.sorted() {
            guard let t = pages[key] else { continue }
            guard t.visibility.contains(context.env) else { continue }
            guard t.metadata.includeInSitemap else { continue }
            guard t.metadata.robots == .allow else { continue }

            locs.append(context.site.compose_address(appending: t.output))
        }

        for key in snippets.keys.sorted() {
            guard let t = snippets[key] else { continue }
            guard t.visibility.contains(context.env) else { continue }
            guard t.metadata.includeInSitemap else { continue }
            guard t.metadata.robots == .allow else { continue }

            locs.append(context.site.compose_address(appending: t.output))
        }

        locs = Array(Set(locs)).sorted()

        var out = """
        <?xml version="1.0" encoding="UTF-8"?>
        <urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">

        """

        for loc in locs {
            out += """
                <url>
                    <loc>\(escapeXml(loc))</loc>
                </url>

            """
        }

        out += """
        </urlset>

        """

        return out
    }

    func escapeXml(_ s: String) -> String {
        s
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "\"", with: "&quot;")
            .replacingOccurrences(of: "'", with: "&apos;")
    }
}
