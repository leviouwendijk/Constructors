import CSS
import Path

public extension RenderBundle.ExportAPI.DocumentAPI {
    struct CSSAPI {
        public let bundle: RenderBundle

        public init(
            bundle: RenderBundle
        ) {
            self.bundle = bundle
        }

        public func string(
            pruneAgainstBundleHTML: Bool = true,
            unreferenced: CSSUnreferenced = .commented,
            indentStep: Int = 4,
            ensureTrailingNewline: Bool = true
        ) -> String {
            let collections = pruneAgainstBundleHTML
                ? bundle.htmlCollectionsForCSS
                : []

            if indentStep == 0 {
                return bundle.stylesheets.minified(
                    forNodeCollections: collections,
                    unreferenced: unreferenced,
                    ensureTrailingNewline: ensureTrailingNewline
                )
            } else {
                return bundle.stylesheets.pretty(
                    forNodeCollections: collections,
                    unreferenced: unreferenced,
                    ensureTrailingNewline: ensureTrailingNewline,
                    indentStep: indentStep
                )
            }
        }

        public func file(
            output: StandardPath,
            pruneAgainstBundleHTML: Bool = true,
            unreferenced: CSSUnreferenced = .commented,
            indentStep: Int = 4,
            ensureTrailingNewline: Bool = true
        ) -> RenderOutput {
            RenderOutput(
                files: [
                    RenderedFile(
                        output: output,
                        content: string(
                            pruneAgainstBundleHTML: pruneAgainstBundleHTML,
                            unreferenced: unreferenced,
                            indentStep: indentStep,
                            ensureTrailingNewline: ensureTrailingNewline
                        )
                    )
                ]
            )
        }

        public func evaluate(
            route: BundleExportRoute? = nil,
            pruneAgainstBundleHTML: Bool = true,
            unreferenced: CSSUnreferenced = .commented,
            indentStep: Int = 4,
            ensureTrailingNewline: Bool = true
        ) -> EvaluatedBundleExport {
            EvaluatedBundleExport(
                kind: .stylesheet,
                bundle: bundle,
                content: string(
                    pruneAgainstBundleHTML: pruneAgainstBundleHTML,
                    unreferenced: unreferenced,
                    indentStep: indentStep,
                    ensureTrailingNewline: ensureTrailingNewline
                ),
                additional_files: [],
                route: route,
                metadata: route?.metadata,
                visibility: route?.visibility ?? [.local, .test, .public],
                metadata_route: nil
            )
        }
    }
}
