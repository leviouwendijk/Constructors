import HTML
import CSS
import JS
import Path
import Primitives

private func _snippet_output_prefix(
    for target: SnippetTargets
) -> GenericPath {
    var prefix = GenericPath(
        ["snippets"]
    )

    if let category = target.sorting_category {
        prefix = prefix.merged(
            appending: GenericPath(
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

            out[key] = target.document_definition(
                id: key
            )
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
                BundleExportDefinition(
                    id: key,
                    visibility: document.visibility,
                    metadata: document.metadata
                ) { context in
                    try document.evaluate(
                        context: context
                    )
                }
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

            exports.append(
                BundleExportDefinition(
                    id: key
                ) { context in
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
                        content: css,
                        additional_files: [],
                        route: BundleExportRoute(
                            output: target.output
                        ),
                        metadata: nil,
                        visibility: [.local, .test, .public],
                        metadata_route: nil
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

            exports.append(
                BundleExportDefinition(
                    id: key,
                    visibility: target.visibility,
                    metadata: target.metadata
                ) { context in
                    let route = BundleExportRoute(
                        output: target.output,
                        visibility: target.visibility,
                        metadata: target.metadata
                    )

                    let metadataRoute = MetadataRoute(
                        output: target.output,
                        visibility: target.visibility,
                        metadata: target.metadata
                    )

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
                            content: html,
                            additional_files: [],
                            route: route,
                            metadata: target.metadata,
                            visibility: target.visibility,
                            metadata_route: metadataRoute
                        )

                    case .external(
                        let cssPath
                    ):
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
                            ],
                            route: route,
                            metadata: target.metadata,
                            visibility: target.visibility,
                            metadata_route: metadataRoute
                        )

                    case .fragment:
                        return EvaluatedBundleExport(
                            kind: .html(.fragment),
                            bundle: target.bundle(),
                            content: target.html.snippet(),
                            additional_files: [],
                            route: route,
                            metadata: target.metadata,
                            visibility: target.visibility,
                            metadata_route: metadataRoute
                        )
                    }
                }
            )
        }

        return exports
    }

    static func export_definitions() throws -> [BundleExportDefinition] {
        try document_exports()
            + stylesheet_exports()
            + snippet_exports()
    }

    static func bundle_exports() -> [BundleExportDefinition] {
        (try? export_definitions()) ?? []
    }
}
