import Foundation
import plate

public struct CSSStyleSheet: Sendable, Equatable {
    public var rules: [CSSRule]

    public init(rules: [CSSRule]) {
        self.rules = rules
    }

    public func render(indentation: Int = 4) -> String {
        var out = ""
        for rule in rules {
            out += "\(rule.selector) {\n"
            for decl in rule.declarations {
                out += "\(decl.property): \(decl.value);".indent(indentation)
                out += "\n"
            }
            out += "}\n\n"
        }
        return out
    }
}
