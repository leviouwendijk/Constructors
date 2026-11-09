import Foundation
import Path
import Primitives

public struct MetadataWriter {
    public let context: BuildContext
    public let writer: OutputWriter

    public init(
        context: BuildContext
    ) {
        self.context = context
        self.writer = OutputWriter(context: context)
    }

    public func write(
        from exports: EvaluatedExportSet
    ) throws {
        try writeMetadataFiles(
            from: exports.metadata_routes
        )
    }

    private func writeMetadataFiles(
        from routes: [MetadataRoute]
    ) throws {
        let robots = renderRobotsTxt(from: routes)
        try writer.write(
            RenderOutput(
                files: [
                    RenderedFile(
                        output: .init(["robots.txt"]),
                        content: robots
                    )
                ]
            )
        )

        let sitemap = renderSitemapXml(from: routes)
        try writer.write(
            RenderOutput(
                files: [
                    RenderedFile(
                        output: .init(["sitemap.xml"]),
                        content: sitemap
                    )
                ]
            )
        )
    }

    private func renderRobotsTxt(
        from routes: [MetadataRoute]
    ) -> String {
        var disallow: [String] = []

        for route in routes {
            guard route.visibility.contains(.public) else {
                continue
            }

            if route.metadata.robots == .disallow {
                disallow.append(
                    route.output.rendered(asRootPath: true)
                )
            }
        }

        disallow = Array(Set(disallow)).sorted()

        var out = "User-agent: *\n"

        if disallow.isEmpty {
            out += "Allow: /\n"
        } else {
            for path in disallow {
                out += "Disallow: \(path)\n"
            }
        }

        let sitemapURL = context.site.root_address() + "sitemap.xml"
        out += "\nSitemap: \(sitemapURL)\n\n"

        return out
    }

    private func renderSitemapXml(
        from routes: [MetadataRoute]
    ) -> String {
        var locs: [String] = []

        for route in routes {
            guard route.visibility.contains(context.env) else {
                continue
            }

            guard route.metadata.includeInSitemap else {
                continue
            }

            guard route.metadata.robots == .allow else {
                continue
            }

            locs.append(
                context.site.compose_address(
                    appending: route.output
                )
            )
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

    private func escapeXml(
        _ string: String
    ) -> String {
        string
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "\"", with: "&quot;")
            .replacingOccurrences(of: "'", with: "&apos;")
    }
}
