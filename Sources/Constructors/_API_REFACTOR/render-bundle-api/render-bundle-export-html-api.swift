import CSS
import HTML
import JS
import Path
import Primitives

public enum BundleHTMLDocumentStyle: Sendable, Equatable {
    case inlined(
        options: BundleHTMLStyleOptions
    )

    case emitted(
        output: StandardPath,
        href: HTMLAssetReference?,
        options: BundleHTMLStyleOptions
    )

    case linked(
        options: BundleHTMLAssetOptions
    )
}

public extension BundleHTMLDocumentStyle {
    static func inline(
        _ options: BundleHTMLStyleOptions = .default
    ) -> Self {
        .inlined(
            options: options
        )
    }

    static func file(
        output: StandardPath,
        href: HTMLAssetReference? = nil,
        options: BundleHTMLStyleOptions = .default
    ) -> Self {
        .emitted(
            output: output,
            href: href,
            options: options
        )
    }

    static func linked(
        _ references: [HTMLAssetReference]
    ) -> Self {
        .linked(
            options: .init(
                linked: references
            )
        )
    }

    static func linked(
        _ options: BundleHTMLAssetOptions
    ) -> Self {
        .linked(
            options: options
        )
    }
}

public enum BundleHTMLDocumentScript: Sendable, Equatable {
    case inlined

    case emitted(
        output: StandardPath,
        src: HTMLAssetReference?,
        options: BundleHTMLScriptOptions
    )
}

public extension BundleHTMLDocumentScript {
    static let inline = BundleHTMLDocumentScript.inlined

    static func file(
        output: StandardPath,
        src: HTMLAssetReference? = nil,
        options: BundleHTMLScriptOptions = .default
    ) -> Self {
        .emitted(
            output: output,
            src: src,
            options: options
        )
    }
}

private struct ResolvedBundleHTMLScriptExport {
    let scripts: [JSScript]
    let files: [RenderedFile]

    func appending(
        to files: [RenderedFile]
    ) -> [RenderedFile] {
        files + self.files
    }
}

private struct ResolvedBundleHTMLDocumentRender {
    let html: String
    let files: [RenderedFile]

    func output(
        htmlOutput: StandardPath
    ) -> RenderOutput {
        RenderOutput(
            files: [
                RenderedFile(
                    output: htmlOutput,
                    content: html
                )
            ] + files
        )
    }
}

public extension RenderBundle.ExportAPI.DocumentAPI {
    struct HTMLAPI {
        public let bundle: RenderBundle

        public init(
            bundle: RenderBundle
        ) {
            self.bundle = bundle
        }

        public func string(
            html_attributes: HTMLAttribute = HTMLAttribute(),
            lang: String? = nil,
            title: String? = nil,
            environment: BuildEnvironment,
            style: BundleHTMLDocumentStyle = .inline(),
            script: BundleHTMLDocumentScript = .inline,
            referenceOptions: HTMLAssetReferenceOptions = .root,
            onGate: @escaping @Sendable (GateEvent) -> Void = { _ in }
        ) -> String {
            renderDocument(
                html_attributes: html_attributes,
                lang: lang,
                title: title,
                environment: environment,
                style: style,
                script: script,
                referenceOptions: referenceOptions,
                onGate: onGate
            ).html
        }

        public func file(
            output: StandardPath,
            html_attributes: HTMLAttribute = HTMLAttribute(),
            lang: String? = nil,
            title: String? = nil,
            environment: BuildEnvironment,
            style: BundleHTMLDocumentStyle = .inline(),
            script: BundleHTMLDocumentScript = .inline,
            referenceOptions: HTMLAssetReferenceOptions = .root,
            onGate: @escaping @Sendable (GateEvent) -> Void = { _ in }
        ) -> RenderOutput {
            renderDocument(
                html_attributes: html_attributes,
                lang: lang,
                title: title,
                environment: environment,
                style: style,
                script: script,
                referenceOptions: referenceOptions,
                onGate: onGate
            ).output(
                htmlOutput: output
            )
        }

        public func evaluate(
            route: BundleExportRoute? = nil,
            html_attributes: HTMLAttribute = HTMLAttribute(),
            lang: String? = nil,
            title: String? = nil,
            environment: BuildEnvironment,
            style: BundleHTMLDocumentStyle = .inline(),
            script: BundleHTMLDocumentScript = .inline,
            referenceOptions: HTMLAssetReferenceOptions = .root,
            onGate: @escaping @Sendable (GateEvent) -> Void = { _ in }
        ) -> EvaluatedBundleExport {
            let rendered = renderDocument(
                html_attributes: html_attributes,
                lang: lang,
                title: title,
                environment: environment,
                style: style,
                script: script,
                referenceOptions: referenceOptions,
                onGate: onGate
            )

            let metadataRoute: MetadataRoute? = {
                guard
                    let route,
                    let metadata = route.metadata
                else {
                    return nil
                }

                return MetadataRoute(
                    output: route.output,
                    visibility: route.visibility,
                    metadata: metadata
                )
            }()

            return EvaluatedBundleExport(
                kind: .html(.document),
                bundle: bundle,
                content: rendered.html,
                additional_files: rendered.files,
                route: route,
                metadata: route?.metadata,
                visibility: route?.visibility ?? [.local, .test, .public],
                metadata_route: metadataRoute
            )
        }

        @available(*, deprecated, message: "use .file(output:...)")
        public func document(
            output: StandardPath,
            html_attributes: HTMLAttribute = HTMLAttribute(),
            lang: String? = nil,
            title: String? = nil,
            environment: BuildEnvironment,
            style: BundleHTMLDocumentStyle = .inline(),
            script: BundleHTMLDocumentScript = .inline,
            referenceOptions: HTMLAssetReferenceOptions = .root,
            onGate: @escaping @Sendable (GateEvent) -> Void = { _ in }
        ) -> RenderOutput {
            file(
                output: output,
                html_attributes: html_attributes,
                lang: lang,
                title: title,
                environment: environment,
                style: style,
                script: script,
                referenceOptions: referenceOptions,
                onGate: onGate
            )
        }

        private func renderDocument(
            html_attributes: HTMLAttribute,
            lang: String?,
            title: String?,
            environment: BuildEnvironment,
            style: BundleHTMLDocumentStyle,
            script: BundleHTMLDocumentScript,
            referenceOptions: HTMLAssetReferenceOptions,
            onGate: @escaping @Sendable (GateEvent) -> Void
        ) -> ResolvedBundleHTMLDocumentRender {
            let resolvedScripts = resolveScripts(
                script,
                referenceOptions: referenceOptions
            )

            let placedScripts = place_scripts(
                resolvedScripts.scripts
            )

            let htmlAttrs = resolvedHTMLAttributes(
                html_attributes,
                lang: lang
            )

            switch style {
                case .inlined(
                    let options
                ):
                    let collections = [
                        bundle.head + placedScripts.head,
                        bundle.body + placedScripts.body
                    ].filter { !$0.isEmpty }

                    let inlineCSS: String?
                    if bundle.stylesheets.isEmpty {
                        inlineCSS = nil
                    } else {
                        inlineCSS = bundle.stylesheets.pretty(
                            forNodeCollections: collections,
                            unreferenced: options.css.unreferenced,
                            ensureTrailingNewline: options.css.ensureTrailingNewline,
                            indentStep: options.css.indentStep
                        )
                    }

                    let doc = HTMLDocument(
                        html: htmlAttrs,
                        head: buildHeadNodes(
                            title: title,
                            linkedStylesheets: options.assets.linked,
                            inlineCSS: inlineCSS,
                            extraHead: bundle.head + placedScripts.head,
                            referenceOptions: referenceOptions
                        ),
                        body: bundle.body + placedScripts.body
                    )

                    let html = doc.render(
                        default: .minified,
                        environment: environment,
                        onGate: onGate
                    )

                    return ResolvedBundleHTMLDocumentRender(
                        html: html,
                        files: resolvedScripts.files
                    )

                case .emitted(
                    let cssOutput,
                    let href,
                    let options
                ):
                    let stylesheetReference = href ?? HTMLAssetReference(cssOutput)

                    let doc = HTMLDocument(
                        html: htmlAttrs,
                        head: buildHeadNodes(
                            title: title,
                            linkedStylesheets: options.assets.linked + [stylesheetReference],
                            inlineCSS: nil,
                            extraHead: bundle.head + placedScripts.head,
                            referenceOptions: referenceOptions
                        ),
                        body: bundle.body + placedScripts.body
                    )

                    let html = doc.render(
                        default: .minified,
                        environment: environment,
                        onGate: onGate
                    )

                    let css = bundle.stylesheets.isEmpty
                        ? ""
                        : bundle.stylesheets.mergedSheet.rendered(
                            forDocuments: [doc],
                            indentStep: options.css.indentStep,
                            ensureTrailingNewline: options.css.ensureTrailingNewline,
                            unreferenced: options.css.unreferenced
                        )

                    let cssFile = RenderedFile(
                        output: cssOutput,
                        content: css
                    )

                    return ResolvedBundleHTMLDocumentRender(
                        html: html,
                        files: resolvedScripts.appending(
                            to: [cssFile]
                        )
                    )

                case .linked(
                    let options
                ):
                    let doc = HTMLDocument(
                        html: htmlAttrs,
                        head: buildHeadNodes(
                            title: title,
                            linkedStylesheets: options.linked,
                            inlineCSS: nil,
                            extraHead: bundle.head + placedScripts.head,
                            referenceOptions: referenceOptions
                        ),
                        body: bundle.body + placedScripts.body
                    )

                    let html = doc.render(
                        default: .minified,
                        environment: environment,
                        onGate: onGate
                    )

                    return ResolvedBundleHTMLDocumentRender(
                        html: html,
                        files: resolvedScripts.files
                    )
            }
        }

        private func resolvedHTMLAttributes(
            _ attributes: HTMLAttribute,
            lang: String?
        ) -> HTMLAttribute {
            var htmlAttrs = attributes

            if let lang {
                htmlAttrs.merge(["lang": lang])
            }

            return htmlAttrs
        }

        private func buildHeadNodes(
            title: String?,
            linkedStylesheets: [HTMLAssetReference],
            inlineCSS: String?,
            extraHead: HTMLFragment,
            referenceOptions: HTMLAssetReferenceOptions
        ) -> HTMLFragment {
            var headNodes: HTMLFragment = [
                HTML.meta(.charset()),
                HTML.meta(.viewport())
            ]

            if let title {
                headNodes.append(
                    HTML.title(title)
                )
            }

            for href in linkedStylesheets {
                headNodes.append(
                    HTML.link(
                        .stylesheet(
                            href: resolve_asset_reference(
                                href,
                                options: referenceOptions
                            )
                        )
                    )
                )
            }

            if let inlineCSS, !inlineCSS.isEmpty {
                headNodes.append(
                    HTML.style(inlineCSS)
                )
            }

            headNodes += extraHead
            return headNodes
        }

        private func resolveScripts(
            _ mode: BundleHTMLDocumentScript,
            referenceOptions: HTMLAssetReferenceOptions
        ) -> ResolvedBundleHTMLScriptExport {
            switch mode {
                case .inlined:
                    return ResolvedBundleHTMLScriptExport(
                        scripts: bundle.scripts.scripts,
                        files: []
                    )

                case .emitted(
                    let output,
                    let src,
                    let options
                ):
                    guard !bundle.scripts.inlineSources.isEmpty else {
                        return ResolvedBundleHTMLScriptExport(
                            scripts: bundle.scripts.scripts,
                            files: []
                        )
                    }

                    let resolvedSRC = resolve_asset_reference(
                        src ?? HTMLAssetReference(output),
                        options: referenceOptions
                    )

                    let emittedScript = JSScript.external(
                        JSExternalSource(resolvedSRC),
                        attributes: options.attributes
                    )

                    let rewrittenScripts = bundle.scripts.replacingInlineScripts(
                        with: emittedScript
                    )

                    let file = RenderedFile(
                        output: output,
                        content: bundle.scripts.renderedInlineFileContent(
                            ensureTrailingNewline: options.ensureTrailingNewline
                        )
                    )

                    return ResolvedBundleHTMLScriptExport(
                        scripts: rewrittenScripts,
                        files: [file]
                    )
            }
        }

        private func resolve_asset_reference(
            _ reference: HTMLAssetReference,
            options: HTMLAssetReferenceOptions
        ) -> String {
            let effective_options = reference.options ?? options

            switch reference.value {
                case .raw(let value):
                    return value

                case .web(let reference):
                    return reference.render(
                        as: effective_options.relativity
                    )
            }
        }
    }
}

public extension RenderBundle.ExportAPI.FragmentAPI {
    struct HTMLAPI {
        public let bundle: RenderBundle

        public init(
            bundle: RenderBundle
        ) {
            self.bundle = bundle
        }

        public func string() -> String {
            let placedScripts = place_scripts(
                bundle.scripts.scripts
            )

            return (
                bundle.body + placedScripts.body
            ).snippet()
        }

        public func file(
            output: StandardPath
        ) -> RenderOutput {
            RenderOutput(
                files: [
                    RenderedFile(
                        output: output,
                        content: string()
                    )
                ]
            )
        }

        public func evaluate(
            route: BundleExportRoute? = nil
        ) -> EvaluatedBundleExport {
            EvaluatedBundleExport(
                kind: .html(.fragment),
                bundle: bundle,
                content: string(),
                additional_files: [],
                route: route,
                metadata: route?.metadata,
                visibility: route?.visibility ?? [.local, .test, .public],
                metadata_route: nil
            )
        }

        @available(*, deprecated, message: "use .file(output:...)")
        public func fragment(
            output: StandardPath
        ) -> RenderOutput {
            file(output: output)
        }
    }
}
