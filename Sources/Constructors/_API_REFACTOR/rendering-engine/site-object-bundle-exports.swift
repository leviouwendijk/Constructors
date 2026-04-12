import HTML
import CSS
import Path
import Primitives

private func _snippet_output_prefix(
    for target: SnippetTargets
) -> StandardPath {
    var prefix = StandardPath(
        ["snippets"]
    )

    if let category = target.sorting_category {
        prefix = prefix.merged(
            appending: StandardPath(
                [category.rawValue]
            )
        )
    }

    return prefix
}

public extension SiteObject {
    static func document_definitions() throws -> [String : SiteDocumentDefinition] {
        let pages = try keyedPages()

        var out: [String : SiteDocumentDefinition] = [:]
        out.reserveCapacity(pages.count)

        for key in pages.keys.sorted() {
            guard let target = pages[key] else {
                continue
            }

            out[key] = SiteDocumentDefinition(
                id: key,
                route: BundleExportRoute(
                    output: target.output,
                    visibility: target.visibility,
                    metadata: target.metadata
                ),
                navigation: target.navigation
            ) { _ in
                target.bundle()
            }
        }

        return out
    }

    static func document_exports() throws -> [BundleExportDefinition] {
        let documents = try document_definitions()

        var exports: [BundleExportDefinition] = []
        exports.reserveCapacity(documents.count)

        for key in documents.keys.sorted() {
            guard let document = documents[key] else {
                continue
            }

            exports.append(
                document.export
            )
        }

        return exports
    }

    static func stylesheet_exports() throws -> [BundleExportDefinition] {
        let stylesheets = try keyedStylesheets()
        let pages = try keyedPages()

        var exports: [BundleExportDefinition] = []
        exports.reserveCapacity(stylesheets.count)

        for key in stylesheets.keys.sorted() {
            guard let target = stylesheets[key] else {
                continue
            }

            let route = BundleExportRoute(
                output: target.output
            )

            exports.append(
                BundleExportDefinition(
                    id: export_key(
                        stylesheetKey: key
                    ),
                    route: route
                ) { context, _ in
                    let visibleDocuments: [HTMLDocument] = pages
                        .keys
                        .sorted()
                        .compactMap { pageKey in
                            guard
                                let page = pages[pageKey],
                                page.visibility.contains(context.env)
                            else {
                                return nil
                            }

                            return page.html()
                        }

                    let options: CSSRenderOptions

                    if target.pruneUnusedSelectors && !visibleDocuments.isEmpty {
                        options = CSSRenderOptions.forDocuments(
                            visibleDocuments,
                            indentStep: target.indentStep,
                            ensureTrailingNewline: true,
                            unreferenced: .commented
                        )
                    } else {
                        options = CSSRenderOptions(
                            indentStep: target.indentStep,
                            ensureTrailingNewline: true
                        )
                    }

                    let css = target.sheet.render(
                        options: options
                    )

                    return EvaluatedBundleExport(
                        kind: .stylesheet,
                        bundle: target.bundle(),
                        content: css
                    )
                }
            )
        }

        return exports
    }

    static func snippet_exports() throws -> [BundleExportDefinition] {
        let snippets = try keyedSnippets()

        var exports: [BundleExportDefinition] = []
        exports.reserveCapacity(snippets.count)

        for key in snippets.keys.sorted() {
            guard let target = snippets[key] else {
                continue
            }

            let route = BundleExportRoute(
                output: target.output,
                visibility: target.visibility,
                metadata: target.metadata
            )

            exports.append(
                BundleExportDefinition(
                    id: export_key(
                        snippetKey: key
                    ),
                    route: route
                ) { context, _ in
                    switch target.mode {
                    case .inline:
                        let html = renderInlineHTML(
                            fragment: target.html,
                            scripts: target.javascript,
                            sheets: target.stylesheets,
                            env: context.env
                        )

                        return EvaluatedBundleExport(
                            kind: .html(.document),
                            bundle: target.bundle(),
                            content: html
                        )

                    case .external(let cssPath):
                        let doc = target.htmlDocument

                        let html = doc.render(
                            default: .pretty,
                            environment: context.env
                        )

                        let cssOptions = CSSRenderOptions.forDocuments(
                            [doc],
                            indentStep: 4,
                            ensureTrailingNewline: true,
                            unreferenced: .commented
                        )

                        let cssText = target.stylesheets
                            .map {
                                $0.render(options: cssOptions)
                            }
                            .joined(separator: "\n\n")

                        let cssOutput = _snippet_output_prefix(
                            for: target
                        ).merged(
                            appending: cssPath
                        )

                        return EvaluatedBundleExport(
                            kind: .html(.document),
                            bundle: target.bundle(),
                            content: html,
                            additional_files: [
                                RenderedFile(
                                    output: cssOutput,
                                    content: cssText
                                )
                            ]
                        )

                    case .fragment:
                        return EvaluatedBundleExport(
                            kind: .html(.fragment),
                            bundle: target.bundle(),
                            content: target.html.snippet()
                        )
                    }
                }
            )
        }

        return exports
    }

    static func export_definitions() throws -> [BundleExportDefinition] {
        if let declaring = Self.self as? any SiteDeclaring.Type {
            return try declaring.declaration_exports()
        }

        return try document_exports()
            + stylesheet_exports()
            + snippet_exports()
    }

    static func bundle_exports() -> [BundleExportDefinition] {
        (try? export_definitions()) ?? []
    }
}
