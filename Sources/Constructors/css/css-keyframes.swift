import Foundation

public struct CSSKeyframeStep: Sendable, Equatable {
    public var selector: String          // "from", "to", "0%", "50%", etc.
    public var declarations: [CSSDeclaration]

    public init(selector: String, declarations: [CSSDeclaration]) {
        self.selector = selector
        self.declarations = declarations
    }
}

public struct CSSKeyframes: Sendable, Equatable {
    public var name: String              // animation name
    public var steps: [CSSKeyframeStep]

    public init(name: String, steps: [CSSKeyframeStep]) {
        self.name = name
        self.steps = steps
    }
}
