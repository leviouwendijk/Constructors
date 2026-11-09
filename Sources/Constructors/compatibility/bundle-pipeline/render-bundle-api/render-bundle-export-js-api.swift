import Path

public extension RenderBundle.ExportAPI.DocumentAPI {
    struct JSAPI {
        public let bundle: RenderBundle

        public init(
            bundle: RenderBundle
        ) {
            self.bundle = bundle
        }

        public func string(
            ensureTrailingNewline: Bool = true
        ) -> String {
            guard !bundle.scripts.inlineSources.isEmpty else {
                return ""
            }

            return bundle.scripts.renderedInlineFileContent(
                ensureTrailingNewline: ensureTrailingNewline
            )
        }

        public func file(
            output: StandardPath,
            ensureTrailingNewline: Bool = true
        ) -> RenderOutput {
            guard !bundle.scripts.inlineSources.isEmpty else {
                return RenderOutput(
                    files: []
                )
            }

            return RenderOutput(
                files: [
                    RenderedFile(
                        output: output,
                        content: string(
                            ensureTrailingNewline: ensureTrailingNewline
                        )
                    )
                ]
            )
        }

        public func evaluate(
            route: BundleExportRoute? = nil,
            ensureTrailingNewline: Bool = true
        ) -> EvaluatedBundleExport {
            EvaluatedBundleExport(
                kind: .javascript,
                bundle: bundle,
                content: string(
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
