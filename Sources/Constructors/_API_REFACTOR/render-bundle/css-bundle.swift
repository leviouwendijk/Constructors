import CSS
import HTML
import JS

public struct CSSBundle: Sendable, Equatable {
    public var sheets: [CSSStyleSheet]

    public init(
        _ sheets: [CSSStyleSheet] = []
    ) {
        self.sheets = sheets
    }

    public var isEmpty: Bool {
        sheets.isEmpty
    }

    public var mergedSheet: CSSStyleSheet {
        CSSStyleSheet.merged(sheets)
    }

    public var pretty: String {
        renderPretty(
            forNodeCollections: [],
            unreferenced: .keep,
            ensureTrailingNewline: true,
            indentStep: 4
        )
    }

    public var minified: String {
        renderMinified(
            forNodeCollections: [],
            unreferenced: .keep,
            ensureTrailingNewline: false
        )
    }

    public func merged(
        with other: CSSBundle
    ) -> CSSBundle {
        CSSBundle(self.sheets + other.sheets)
    }

    public func pretty(
        forNodes nodes: HTMLFragment,
        unreferenced: CSSUnreferenced = .commented,
        ensureTrailingNewline: Bool = true,
        indentStep: Int = 4
    ) -> String {
        renderPretty(
            forNodeCollections: [nodes],
            unreferenced: unreferenced,
            ensureTrailingNewline: ensureTrailingNewline,
            indentStep: indentStep
        )
    }

    public func pretty(
        forNodeCollections collections: [HTMLFragment],
        unreferenced: CSSUnreferenced = .commented,
        ensureTrailingNewline: Bool = true,
        indentStep: Int = 4
    ) -> String {
        renderPretty(
            forNodeCollections: collections,
            unreferenced: unreferenced,
            ensureTrailingNewline: ensureTrailingNewline,
            indentStep: indentStep
        )
    }

    public func minified(
        forNodes nodes: HTMLFragment,
        unreferenced: CSSUnreferenced = .drop,
        ensureTrailingNewline: Bool = false
    ) -> String {
        renderMinified(
            forNodeCollections: [nodes],
            unreferenced: unreferenced,
            ensureTrailingNewline: ensureTrailingNewline
        )
    }

    public func minified(
        forNodeCollections collections: [HTMLFragment],
        unreferenced: CSSUnreferenced = .drop,
        ensureTrailingNewline: Bool = false
    ) -> String {
        renderMinified(
            forNodeCollections: collections,
            unreferenced: unreferenced,
            ensureTrailingNewline: ensureTrailingNewline
        )
    }

    private func renderPretty(
        forNodeCollections collections: [HTMLFragment],
        unreferenced: CSSUnreferenced,
        ensureTrailingNewline: Bool,
        indentStep: Int
    ) -> String {
        let filtered = collections.filter { !$0.isEmpty }

        if filtered.isEmpty {
            return mergedSheet.render(
                options: CSSRenderOptions(
                    indentStep: indentStep,
                    ensureTrailingNewline: ensureTrailingNewline,
                    unreferenced: unreferenced,
                    mergeDuplicateSelectors: true
                )
            )
        }

        return CSSStyleSheet.renderedMerged(
            sheets,
            forNodeCollections: filtered,
            indentStep: indentStep,
            ensureTrailingNewline: ensureTrailingNewline,
            unreferenced: unreferenced
        )
    }

    private func renderMinified(
        forNodeCollections collections: [HTMLFragment],
        unreferenced: CSSUnreferenced,
        ensureTrailingNewline: Bool
    ) -> String {
        let rendered = renderPretty(
            forNodeCollections: collections,
            unreferenced: unreferenced,
            ensureTrailingNewline: ensureTrailingNewline,
            indentStep: 0
        )

        return Self.compact(rendered)
    }

    private static func compact(
        _ css: String
    ) -> String {
        css
            .replacingOccurrences(of: "\n", with: "")
            .replacingOccurrences(of: "\t", with: "")
            .replacingOccurrences(of: " {", with: "{")
            .replacingOccurrences(of: "{ ", with: "{")
            .replacingOccurrences(of: ": ", with: ":")
            .replacingOccurrences(of: "; ", with: ";")
            .replacingOccurrences(of: ", ", with: ",")
            .replacingOccurrences(of: "} ", with: "}")
            .replacingOccurrences(of: ";}", with: "}")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

