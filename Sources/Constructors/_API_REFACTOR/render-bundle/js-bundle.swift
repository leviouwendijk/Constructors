import JS

public struct JSBundle: Sendable, Equatable {
    public var scripts: [JSScript]

    public init(
        _ scripts: [JSScript] = []
    ) {
        self.scripts = scripts
    }

    public var isEmpty: Bool {
        scripts.isEmpty
    }

    public var inlineScripts: [JSScript] {
        scripts.compactMap {
            switch $0 {
            case .inline:
                return $0
            case .external:
                return nil
            }
        }
    }

    public var externalScripts: [JSScript] {
        scripts.compactMap {
            switch $0 {
            case .inline:
                return nil
            case .external:
                return $0
            }
        }
    }

    public var inlineSources: [JSSource] {
        scripts.compactMap {
            switch $0 {
            case .inline(let source, _):
                return source
            case .external:
                return nil
            }
        }
    }

    public var mergedInlineSource: JSSource {
        inlineSources.joinedSource(separator: "\n")
    }

    public func merged(
        with other: JSBundle
    ) -> JSBundle {
        JSBundle(
            self.scripts + other.scripts
        )
    }

    public func renderedInlineFileContent(
        ensureTrailingNewline: Bool = true
    ) -> String {
        mergedInlineSource.rendered_file_content(
            ensure_trailing_newline: ensureTrailingNewline
        )
    }

    public func replacingInlineScripts(
        with externalReplacement: JSScript?
    ) -> [JSScript] {
        var out: [JSScript] = []
        out.reserveCapacity(scripts.count)

        var insertedReplacement = false

        for script in scripts {
            switch script {
            case .inline:
                if !insertedReplacement, let externalReplacement {
                    out.append(externalReplacement)
                    insertedReplacement = true
                }

            case .external:
                out.append(script)
            }
        }

        if !insertedReplacement,
           !inlineScripts.isEmpty,
           let externalReplacement
        {
            out.append(externalReplacement)
        }

        return out
    }
}
