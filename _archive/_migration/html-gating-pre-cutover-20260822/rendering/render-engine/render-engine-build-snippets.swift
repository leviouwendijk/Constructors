import Foundation
import HTML
import CSS

extension RenderEngine {
    public func buildSnippets(
        snippetID: String?
    ) throws {
        // let isDefaultEmpty = try Registry.DefaultEmptyType.check(
        //     for: context.site,
        //     target: .snippets,
        //     verbose: context.verbose
        // )

        let is_empty_default = try SiteObjectComponent.snippets.check(
            for: context.site_object,
            verbose: context.verbose
        )

        if is_empty_default {
            stderr("No snippets configured, empty defaults found.\n")
            return
        }

        // let snippets = Registry.snippets(for: context.site)
        let snippets = try context.site_object.keyedSnippets()

        let selected: [(String, SnippetTargets)] = snippets
            .filter { key, _ in
                if let snippetID { return key == snippetID }
                return true
            }
            .sorted { $0.key < $1.key }

        guard !selected.isEmpty else {
            throw RenderingError.snippetNotFound(site: context.site, id: snippetID ?? "<none>")
        }

        for (id, snippet) in selected {
            if !snippet.isVisible(in: context.env) {
                stderr("skipped snippet \(context.site.rawValue)/\(id) (hidden for \(context.env))\n")
                continue
            }

            let sink = GateTallySink()

            switch snippet.mode {
            case .inline:
                let html = renderInlineHTML(
                    fragment: snippet.html,
                    sheets: snippet.stylesheets,
                    env: context.env,
                    onGate: { e in sink.record(e) }
                )

                let outURL: URL = snippet.url(base_url: context.baseURL)
                let htmlOut = snippet.htmlOutput.url(base: outURL)

                try FileManager.default.createDirectory(
                    at: htmlOut.deletingLastPathComponent(),
                    withIntermediateDirectories: true
                )

                try context.env.write(content: html, to: htmlOut)

                stderr("wrote snippet \(context.site.rawValue)/\(id) → \(htmlOut.path)\n\n")

            case .external(let cssPath):
                let doc = snippet.htmlDocument
                let html = doc.render(
                    default: .pretty,
                    environment: context.env,
                    onGate: { e in sink.record(e) }
                )

                let outURL: URL = snippet.url(base_url: context.baseURL)
                let htmlOut = snippet.htmlOutput.url(base: outURL)

                try FileManager.default.createDirectory(
                    at: htmlOut.deletingLastPathComponent(),
                    withIntermediateDirectories: true
                )
                try context.env.write(content: html, to: htmlOut)

                let cssOptions = CSSRenderOptions.forDocuments(
                    [snippet.htmlDocument],
                    indentStep: 4,
                    ensureTrailingNewline: true,
                    unreferenced: .commented
                )

                let cssText = snippet.stylesheets
                    .map { $0.render(options: cssOptions) }
                    .joined(separator: "\n\n")

                let cssOut = cssPath.url(base: outURL)

                try FileManager.default.createDirectory(
                    at: cssOut.deletingLastPathComponent(),
                    withIntermediateDirectories: true
                )
                try context.env.write(content: cssText, to: cssOut)

                stderr("wrote snippet \(context.site.rawValue)/\(id) HTML → \(htmlOut.path)\n")
                stderr("wrote snippet \(context.site.rawValue)/\(id) CSS  → \(cssOut.path)\n\n")

            case .fragment:
                let html = snippet.html.snippet()
                let outURL: URL = snippet.url(base_url: context.baseURL)
                let finalURL = snippet.htmlOutput.url(base: outURL)

                try FileManager.default.createDirectory(
                    at: finalURL.deletingLastPathComponent(),
                    withIntermediateDirectories: true
                )

                try context.env.write(content: html, to: finalURL)

                stderr("wrote snippet \(context.site.rawValue)/\(id) → \(finalURL.path)\n\n")
            }

            let summary = sink.snapshot().prettySummary(site: context.site, page: id, env: context.env)
            if !summary.isEmpty {
                stderr(summary)
            }
        }
    }
}
