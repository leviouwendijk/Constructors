import CSS
import HTML

private func collectedSymbols(
    from document: HTMLDocument
) -> HTMLSymbols {
    return HTMLSymbolCollector.collect(
        from: [
            HTML.html(document.html_attributes) {
                HTML.head {
                    document.head
                }
                HTML.body {
                    document.body
                }
            }
        ]
    )
}

extension CSSRenderOptions {
    public static func forNodes(
        _ nodes: HTMLFragment,
        indentStep: Int = 4,
        ensureTrailingNewline: Bool = false,
        unreferenced: CSSUnreferenced = .keep,
        mergeDuplicateSelectors: Bool = true
    ) -> CSSRenderOptions {
        let symbols = HTMLSymbolCollector.collect(from: nodes)
        return CSSRenderOptions(
            indentStep: indentStep,
            ensureTrailingNewline: ensureTrailingNewline,
            usedClassNames: symbols.classes,
            usedIDs: symbols.ids,
            unreferenced: unreferenced,
            mergeDuplicateSelectors: mergeDuplicateSelectors
        )
    }

    public static func forNode(
        _ node: any HTMLNode,
        indentStep: Int = 4,
        ensureTrailingNewline: Bool = false,
        unreferenced: CSSUnreferenced = .keep,
        mergeDuplicateSelectors: Bool = true
    ) -> CSSRenderOptions {
        forNodes(
            [node],
            indentStep: indentStep,
            ensureTrailingNewline: ensureTrailingNewline,
            unreferenced: unreferenced,
            mergeDuplicateSelectors: mergeDuplicateSelectors
        )
    }
}

extension CSSRenderOptions {
    public static func forDocument(
        _ document: HTMLDocument,
        indentStep: Int = 4,
        ensureTrailingNewline: Bool = false,
        unreferenced: CSSUnreferenced = .keep,
        mergeDuplicateSelectors: Bool = true
    ) -> CSSRenderOptions {
        let symbols = collectedSymbols(from: document)

        return CSSRenderOptions(
            indentStep: indentStep,
            ensureTrailingNewline: ensureTrailingNewline,
            usedClassNames: symbols.classes,
            usedIDs: symbols.ids,
            unreferenced: unreferenced,
            mergeDuplicateSelectors: mergeDuplicateSelectors
        )
    }

    public static func forDocuments(
        _ documents: [HTMLDocument],
        indentStep: Int = 4,
        ensureTrailingNewline: Bool = false,
        unreferenced: CSSUnreferenced = .keep,
        mergeDuplicateSelectors: Bool = true
    ) -> CSSRenderOptions {
        var usedClasses = Set<String>()
        var usedIDs = Set<String>()

        for doc in documents {
            let symbols = collectedSymbols(from: doc)
            usedClasses.formUnion(symbols.classes)
            usedIDs.formUnion(symbols.ids)
        }

        return CSSRenderOptions(
            indentStep: indentStep,
            ensureTrailingNewline: ensureTrailingNewline,
            usedClassNames: usedClasses,
            usedIDs: usedIDs,
            unreferenced: unreferenced,
            mergeDuplicateSelectors: mergeDuplicateSelectors
        )
    }
}
