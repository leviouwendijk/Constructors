import Foundation

public struct CSSRule: Sendable, Equatable, CSSNode {
    public var selector: String           // ".container", "body", "@media ...", etc.
    public var declarations: [CSSDeclaration]

    public init(selector: String, declarations: [CSSDeclaration]) {
        self.selector = selector
        self.declarations = declarations
    }
}

public typealias CSSRuleMetaSection = CSSMetaSection<CSSRule>

extension CSSRuleMetaSection {
    public func customProperties(
        selector: String = ":root",
        filter: ((CSSCustomProperty) -> Bool)? = nil
    ) -> [CSSCustomProperty] {
        _extractCustomCSSProperties(from: items, selector: selector, filter: filter)
    }
}
