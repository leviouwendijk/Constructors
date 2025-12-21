import Foundation
import HTML
import CSS

extension RenderEngine {
    public func buildStyles(
        documents: [HTMLDocument]
    ) throws {
        // let isDefaultEmpty = try Registry.DefaultEmptyType.check(
        //     for: context.site,
        //     target: .stylesheets,
        //     verbose: context.verbose
        // )

        let is_empty_default = try SiteObjectComponent.stylesheets.check(
            for: context.site_object,
            verbose: context.verbose
        )

        if is_empty_default {
            stderr("No stylesheets configured, empty defaults found.\n")
            return
        }

        // let styleTargets = Registry.styles(for: context.site)
        let styleTargets = try context.site_object.keyedStylesheets()

        guard !styleTargets.isEmpty else { return }
        guard !documents.isEmpty else { return }

        // for style in styleTargets {
        for (_, style) in styleTargets.sorted(by: { $0.key < $1.key }) {
            let options: CSSRenderOptions
            if style.pruneUnusedSelectors {
                options = CSSRenderOptions.forDocuments(
                    documents,
                    indentStep: style.indentStep,
                    ensureTrailingNewline: true,
                    unreferenced: .commented
                )
            } else {
                options = CSSRenderOptions(
                    indentStep: style.indentStep,
                    ensureTrailingNewline: true
                )
            }

            let css = style.sheet.render(options: options)
            let outURL = style.output.url(base: context.baseURL)

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
                try context.env.write(content: css, to: outURL)
            } catch {
                throw RenderingError.writeFailed(url: outURL, underlying: error)
            }

            stderr(
                """
                wrote \(context.site.rawValue)/\(style.name) stylesheet
                    → \(outURL.path)

                """
            )
        }
    }
}
