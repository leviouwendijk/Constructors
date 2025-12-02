import Foundation
import plate

public enum CSSUnreferenced: Sendable {
    /// Leave all rules unchanged, no pruning.
    case keep
    /// Drop rules that are *provably* unused.
    case drop
    /// Keep unused rules, but wrap them in a comment block so they are still visible.
    case commented
}

public struct CSSRenderOptions: Sendable {
    public var indentStep: Int
    public var ensureTrailingNewline: Bool

    /// Classes seen in the HTML.
    public var usedClassNames: Set<String>?

    /// IDs seen in the HTML.
    public var usedIDs: Set<String>?

    public var unreferenced: CSSUnreferenced

    public var mergeDuplicateSelectors: Bool

    public init(
        indentStep: Int = 4,
        ensureTrailingNewline: Bool = false,
        usedClassNames: Set<String>? = nil,
        usedIDs: Set<String>? = nil,
        unreferenced: CSSUnreferenced = .keep,
        mergeDuplicateSelectors: Bool = true
    ) {
        self.indentStep = indentStep
        self.ensureTrailingNewline = ensureTrailingNewline
        self.usedClassNames = usedClassNames
        self.usedIDs = usedIDs
        self.unreferenced = unreferenced
        self.mergeDuplicateSelectors = mergeDuplicateSelectors
    }
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
            forNodes([node], 
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
        CSSRenderOptions(
            indentStep: indentStep,
            ensureTrailingNewline: ensureTrailingNewline,
            usedClassNames: document.collectedClassNames(),
            usedIDs: document.collectedIDs(),
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
            usedClasses.formUnion(doc.collectedClassNames())
            usedIDs.formUnion(doc.collectedIDs())
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
