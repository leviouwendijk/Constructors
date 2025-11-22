import Foundation

public enum CSS {
    // Declarations
    public static func decl(_ property: String, _ value: String) -> CSSDeclaration {
        CSSDeclaration(property: property, value: value)
    }

    // Rules (string-based)
    public static func rule(_ selector: String, _ declarations: [CSSDeclaration]) -> CSSRule {
        CSSRule(selector: selector, declarations: declarations)
    }

    public static func rule(_ selector: String, _ declarations: CSSDeclaration...) -> CSSRule {
        CSSRule(selector: selector, declarations: declarations)
    }

    // Rules (selector-based)
    public static func rule(_ selector: CSSSelector, _ declarations: [CSSDeclaration]) -> CSSRule {
        CSSRule(selector: selector.raw, declarations: declarations)
    }

    public static func rule(_ selector: CSSSelector, _ declarations: CSSDeclaration...) -> CSSRule {
        CSSRule(selector: selector.raw, declarations: declarations)
    }

    // Media
    public static func media(_ query: String, _ rules: [CSSRule]) -> CSSMedia {
        CSSMedia(query: query, rules: rules)
    }

    public static func media(_ query: String, _ rules: CSSRule...) -> CSSMedia {
        CSSMedia(query: query, rules: rules)
    }

    public static func inline(_ declarations: [CSSDeclaration]) -> String {
        declarations
            .map { "\($0.property): \($0.value);" }
            .joined(separator: " ")
    }

    public static func inline(_ declarations: CSSDeclaration...) -> String {
        inline(declarations)
    }

    // MARK: - Keyframes

    @resultBuilder
    public enum CSSKeyframeStepBuilder {
        public static func buildBlock(_ parts: [CSSKeyframeStep]...) -> [CSSKeyframeStep] {
            parts.flatMap { $0 }
        }

        public static func buildArray(_ parts: [[CSSKeyframeStep]]) -> [CSSKeyframeStep] {
            parts.flatMap { $0 }
        }

        public static func buildEither(first: [CSSKeyframeStep]) -> [CSSKeyframeStep] {
            first
        }

        public static func buildEither(second: [CSSKeyframeStep]) -> [CSSKeyframeStep] {
            second
        }

        public static func buildOptional(_ part: [CSSKeyframeStep]?) -> [CSSKeyframeStep] {
            part ?? []
        }

        public static func buildExpression(_ step: CSSKeyframeStep) -> [CSSKeyframeStep] {
            [step]
        }

        public static func buildExpression(_ steps: [CSSKeyframeStep]) -> [CSSKeyframeStep] {
            steps
        }
    }

    public static func keyframes(
        _ name: String,
        @CSSKeyframeStepBuilder _ steps: () -> [CSSKeyframeStep]
    ) -> CSSKeyframes {
        CSSKeyframes(name: name, steps: steps())
    }

    public static func step(
        _ selector: String,
        _ declarations: [CSSDeclaration]
    ) -> CSSKeyframeStep {
        CSSKeyframeStep(selector: selector, declarations: declarations)
    }

    public static func step(
        _ selector: String,
        @CSSDeclBuilder _ declarations: () -> [CSSDeclaration]
    ) -> CSSKeyframeStep {
        CSSKeyframeStep(selector: selector, declarations: declarations())
    }

    public static func from(
        @CSSDeclBuilder _ declarations: () -> [CSSDeclaration]
    ) -> CSSKeyframeStep {
        CSSKeyframeStep(selector: "from", declarations: declarations())
    }

    public static func to(
        @CSSDeclBuilder _ declarations: () -> [CSSDeclaration]
    ) -> CSSKeyframeStep {
        CSSKeyframeStep(selector: "to", declarations: declarations())
    }

    public static func pct(
        _ value: Int,
        @CSSDeclBuilder _ declarations: () -> [CSSDeclaration]
    ) -> CSSKeyframeStep {
        CSSKeyframeStep(selector: "\(value)%", declarations: declarations())
    }
}
