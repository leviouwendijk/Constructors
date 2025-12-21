import CSS
import HTML

extension CSSStyleSheet {
    /// Render this stylesheet, pruned against multiple HTML fragments.
    /// Useful if you already have several node collections (pages, components, etc.).
    public func rendered(
        forNodeCollections collections: [HTMLFragment],
        indentStep: Int = 4,
        ensureTrailingNewline: Bool = true,
        unreferenced: CSSUnreferenced = .drop
    ) -> String {
        var usedClasses = Set<String>()
        var usedIDs = Set<String>()

        // for nodes in collections {
        //     let doc = nodes.htmlDocument
        //     usedClasses.formUnion(doc.collectedClassNames())
        //     usedIDs.formUnion(doc.collectedIDs())
        // }
        for nodes in collections {
            let symbols = HTMLSymbolCollector.collect(from: nodes)
            usedClasses.formUnion(symbols.classes)
            usedIDs.formUnion(symbols.ids)
        }

        let options = CSSRenderOptions(
            indentStep: indentStep,
            ensureTrailingNewline: ensureTrailingNewline,
            usedClassNames: usedClasses,
            usedIDs: usedIDs,
            unreferenced: unreferenced
        )

        return render(options: options)
    }

    /// Render this stylesheet, pruned against a single HTML fragment.
    public func rendered(
        forNodes nodes: HTMLFragment,
        indentStep: Int = 4,
        ensureTrailingNewline: Bool = true,
        unreferenced: CSSUnreferenced = .drop
    ) -> String {
        let options = CSSRenderOptions.forNodes(
            nodes,
            indentStep: indentStep,
            ensureTrailingNewline: ensureTrailingNewline,
            unreferenced: unreferenced
        )
        return render(options: options)
    }

    /// Convenience: merged sheets → single rendered bundle for given node collections.
    public static func renderedMerged(
        _ sheets: [CSSStyleSheet],
        forNodeCollections collections: [HTMLFragment],
        indentStep: Int = 4,
        ensureTrailingNewline: Bool = true,
        unreferenced: CSSUnreferenced = .drop
    ) -> String {
        CSSStyleSheet.merged(sheets).rendered(
            forNodeCollections: collections,
            indentStep: indentStep,
            ensureTrailingNewline: ensureTrailingNewline,
            unreferenced: unreferenced
        )
    }

    public func rendered(
        forDocuments documents: [HTMLDocument],
        indentStep: Int = 4,
        ensureTrailingNewline: Bool = true,
        unreferenced: CSSUnreferenced = .drop
    ) -> String {
        let options = CSSRenderOptions.forDocuments(
            documents,
            indentStep: indentStep,
            ensureTrailingNewline: ensureTrailingNewline,
            unreferenced: unreferenced
        )
        return render(options: options)
    }
}

extension CSSStyleSheet {
    /// Returns all custom properties (`--foo`) from rules matching `selector`.
    ///
    /// - Parameters:
    ///   - selector: CSS selector to match rules on (defaults to `:root`).
    ///   - filter:   Optional filter on the resulting tokens.
    public func customProperties(
        selector: String = ":root",
        filter: ((CSSCustomProperty) -> Bool)? = nil
    ) -> [CSSCustomProperty] {
        _extractCustomCSSProperties(from: rules, selector: selector, filter: filter)
    }

    public func renderedStyleProfile(
        title: String,
        subtitle: String? = nil,
        selector: String = ":root",
        includeUngroupedGroup: Bool = true,
        ungroupedTitle: String = "Other tokens"
    ) -> RenderedStyleProfile {
        RenderedStyleProfile.fromStyleSheet(
            self,
            title: title,
            subtitle: subtitle,
            selector: selector,
            includeUngroupedGroup: includeUngroupedGroup,
            ungroupedTitle: ungroupedTitle
        )
    }
}
