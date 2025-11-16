import Foundation

/// Build environments we care about for feature gating.
public enum BuildEnvironment: Sendable {
    case local
    case test
    case `public`
}

public struct GateEvent: Sendable {
    public let id: String?
    public let allowed: Set<BuildEnvironment>
    public let environment: BuildEnvironment
    public let rendered: Bool
}

public struct HTMLRenderOptions: Sendable {
    // @avialable(*, message: "replaced by indentation: and newline: and trailingNewline:") public var pretty: Bool
    public var indentation: Bool
    public var newlineSeparated: Bool
    public var indentStep: Int
    public var attributeOrder: HTMLAttributeOrder
    public var ensureTrailingNewline: Bool
    public var environment: BuildEnvironment

    public var onGate: (@Sendable (GateEvent) -> Void)?

    public init(
        pretty: Bool = true,
        indentStep: Int = 4,
        attributeOrder: HTMLAttributeOrder = .preserve,
        ensureTrailingNewline: Bool = true,
        environment: BuildEnvironment = .local,
        onGate: (@Sendable (GateEvent) -> Void)? = nil
    ) {
        self.indentation = pretty
        self.newlineSeparated = pretty

        self.indentStep = indentStep
        self.attributeOrder = attributeOrder
        self.ensureTrailingNewline = ensureTrailingNewline

        self.environment = environment
        self.onGate = onGate
    }
    
    public init(
        // pretty: Bool = true,
        indentation: Bool = true,
        newlineSeparated: Bool = true,
        indentStep: Int = 4,
        attributeOrder: HTMLAttributeOrder = .preserve,
        ensureTrailingNewline: Bool = true,
        environment: BuildEnvironment = .local,
        onGate: (@Sendable (GateEvent) -> Void)? = nil
    ) {
        self.indentation = indentation
        self.newlineSeparated = newlineSeparated
        self.indentStep = indentStep
        self.attributeOrder = attributeOrder
        self.ensureTrailingNewline = ensureTrailingNewline
        self.environment = environment
        self.onGate = onGate
    }
}

extension HTMLRenderOptions {
    public enum Defaults {
        /// Pretty, indented output with sane defaults and environment/gate hook.
        public static func pretty(
            indentStep: Int = 4,
            attributeOrder: HTMLAttributeOrder = .preserve,
            ensureTrailingNewline: Bool = true,
            environment: BuildEnvironment = .local,
            onGate: (@Sendable (GateEvent) -> Void)? = nil
        ) -> HTMLRenderOptions {
            return HTMLRenderOptions(
                pretty: true,
                indentStep: indentStep,
                attributeOrder: attributeOrder,
                ensureTrailingNewline: ensureTrailingNewline,
                environment: environment,
                onGate: onGate
            )
        }

        /// Compact/minified-ish rendering, useful for emails or prod assets.
        public static func minified(
            attributeOrder: HTMLAttributeOrder = .preserve,
            ensureTrailingNewline: Bool = false,
            environment: BuildEnvironment = .public,
            onGate: (@Sendable (GateEvent) -> Void)? = nil
        ) -> HTMLRenderOptions {
            return HTMLRenderOptions(
                indentation: false,
                newlineSeparated: false,
                indentStep: 0,
                attributeOrder: attributeOrder,
                ensureTrailingNewline: ensureTrailingNewline,
                environment: environment,
                onGate: onGate
            )
        }
    }
}
