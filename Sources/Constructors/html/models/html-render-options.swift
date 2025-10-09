import Foundation

public struct HTMLRenderOptions: Sendable {
    public var pretty: Bool
    public var indentStep: Int
    public var attributeOrder: HTMLAttributeOrder
    public var ensureTrailingNewline: Bool

    public init(
        pretty: Bool = true,
        indentStep: Int = 4,
        attributeOrder: HTMLAttributeOrder = .preserve,
        ensureTrailingNewline: Bool = true
    ) {
        self.pretty = pretty
        self.indentStep = indentStep
        self.attributeOrder = attributeOrder
        self.ensureTrailingNewline = ensureTrailingNewline
    }
}
