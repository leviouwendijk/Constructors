import CSS
import HTML

public protocol ReusableComponent: Sendable {
    func html() -> HTMLFragment
    func styles() -> [CSSStyleSheet]
}

public extension Array where Element == any ReusableComponent {
    func gathered_styles() -> [CSSStyleSheet] {
        var out: [CSSStyleSheet] = []
        for c in self {
            out.append(contentsOf: c.styles())
        }
        return out
    }
}
