import Foundation

/// Build environments we care about for feature gating.
public enum BuildEnvironment: Sendable {
    case local
    case test
    case `public`
}

public struct HTMLRenderOptions: Sendable {
    // @avialable(*, message: "replaced by indentation: and newline: and trailingNewline:") public var pretty: Bool
    public var indentation: Bool
    public var newlineSeparated: Bool
    public var indentStep: Int
    public var attributeOrder: HTMLAttributeOrder
    public var ensureTrailingNewline: Bool
    public var environment: BuildEnvironment

    public init(
        pretty: Bool = true,
        indentStep: Int = 4,
        attributeOrder: HTMLAttributeOrder = .preserve,
        ensureTrailingNewline: Bool = true,
        environment: BuildEnvironment = .local
    ) {
        self.indentation = pretty
        self.newlineSeparated = pretty

        self.indentStep = indentStep
        self.attributeOrder = attributeOrder
        self.ensureTrailingNewline = ensureTrailingNewline

        self.environment = environment
    }
    
    public init(
        // pretty: Bool = true,
        indentation: Bool = true,
        newlineSeparated: Bool = true,
        indentStep: Int = 4,
        attributeOrder: HTMLAttributeOrder = .preserve,
        ensureTrailingNewline: Bool = true,
        environment: BuildEnvironment = .local
    ) {
        self.indentation = indentation
        self.newlineSeparated = newlineSeparated
        self.indentStep = indentStep
        self.attributeOrder = attributeOrder
        self.ensureTrailingNewline = ensureTrailingNewline
        self.environment = environment
    }
}
