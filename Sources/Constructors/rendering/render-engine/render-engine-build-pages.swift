import Foundation
import HTML

extension RenderEngine {
    @discardableResult
    public func buildPages() throws -> [HTMLDocument] {
        let is_empty_default = try SiteObjectComponent.pages.check(
            for: context.site_object,
            verbose: context.verbose
        )

        if is_empty_default {
            stderr("No pages configured, empty defaults found.\n")
            return []
        }

        // let pages = try Registry.pageMap(for: context.site)
        let pages = try context.site_object.keyedPages()

        var documents: [HTMLDocument] = []
        documents.reserveCapacity(pages.count)

        // for (pageName, target) in pages.sorted(by: { $0.key < $1.key }) {
        for pageName in pages.keys.sorted() {
            guard let target = pages[pageName] else {
                throw RenderingError.pageNotFound(site: context.site, page: pageName)
            }

            guard target.visibility.contains(context.env) else {
                stderr(
                    """
                    skipped \(context.site.rawValue)/\(pageName)
                        (hidden for \(context.env))

                    """
                )
                continue
            }

            let sink = GateTallySink()

            let doc = target.html()
            let html = doc.render(
                default: .pretty,
                environment: context.env,
                onGate: { e in sink.record(e) }
            )

            let outURL = target.output.url(base: context.baseURL)

            do {
                try FileManager.default.createDirectory(
                    at: outURL.deletingLastPathComponent(),
                    withIntermediateDirectories: true
                )
            } catch {
                throw RenderingError.createDirFailed(
                    url: outURL.deletingLastPathComponent(),
                    underlying: error
                )
            }

            do {
                try context.env.write(content: html, to: outURL)
            } catch {
                throw RenderingError.writeFailed(url: outURL, underlying: error)
            }

            documents.append(doc)

            stderr(
                """
                wrote \(context.site.rawValue)/\(pageName)
                    → \(outURL.path)

                """
            )

            if context.showGates {
                let summary = sink.snapshot().prettySummary(
                    site: context.site,
                    page: pageName,
                    env: context.env
                )
                if !summary.isEmpty {
                    stderr(summary)
                }
            }

            stderr("\n")
        }

        return documents
    }
}
