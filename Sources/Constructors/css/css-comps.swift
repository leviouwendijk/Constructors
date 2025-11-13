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
    public static func media(_ query: String, _ rules: [CSSRule]) -> CSSMediaBlock {
        CSSMediaBlock(query: query, rules: rules)
    }

    public static func media(_ query: String, _ rules: CSSRule...) -> CSSMediaBlock {
        CSSMediaBlock(query: query, rules: rules)
    }
}
