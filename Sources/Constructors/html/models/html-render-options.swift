import Foundation

public struct HTMLRenderOptions: Sendable {
    // @avialable(*, message: "replaced by indentation: and newline: and trailingNewline:") public var pretty: Bool
    public var indentation: Bool
    public var newlineSeparated: Bool
    public var indentStep: Int
    public var attributeOrder: HTMLAttributeOrder
    public var ensureTrailingNewline: Bool

    public init(
        pretty: Bool = true,
        indentStep: Int = 4,
        attributeOrder: HTMLAttributeOrder = .preserve,
        ensureTrailingNewline: Bool = true
    ) {
        self.indentation = pretty
        self.newlineSeparated = pretty

        self.indentStep = indentStep
        self.attributeOrder = attributeOrder
        self.ensureTrailingNewline = ensureTrailingNewline
    }
    
    public init(
        // pretty: Bool = true,
        indentation: Bool = true,
        newlineSeparated: Bool = true,
        indentStep: Int = 4,
        attributeOrder: HTMLAttributeOrder = .preserve,
        ensureTrailingNewline: Bool = true
    ) {
        self.indentation = indentation
        self.newlineSeparated = newlineSeparated
        self.indentStep = indentStep
        self.attributeOrder = attributeOrder
        self.ensureTrailingNewline = ensureTrailingNewline
    }
}
