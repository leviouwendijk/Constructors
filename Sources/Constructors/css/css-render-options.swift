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

    public init(
        indentStep: Int = 4,
        ensureTrailingNewline: Bool = false,
        usedClassNames: Set<String>? = nil,
        usedIDs: Set<String>? = nil,
        unreferenced: CSSUnreferenced = .keep
    ) {
        self.indentStep = indentStep
        self.ensureTrailingNewline = ensureTrailingNewline
        self.usedClassNames = usedClassNames
        self.usedIDs = usedIDs
        self.unreferenced = unreferenced
    }
}

public extension CSSRenderOptions {
    static func forDocument(
        _ document: HTMLDocument,
        indentStep: Int = 4,
        ensureTrailingNewline: Bool = false,
        unreferenced: CSSUnreferenced = .keep
    ) -> CSSRenderOptions {
        CSSRenderOptions(
            indentStep: indentStep,
            ensureTrailingNewline: ensureTrailingNewline,
            usedClassNames: document.collectedClassNames(),
            usedIDs: document.collectedIDs(),
            unreferenced: unreferenced
        )
    }
}
