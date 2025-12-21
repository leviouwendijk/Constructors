import CSS
import HTML

public protocol WebComponent: Sendable {
    func html() -> HTMLFragment
    func styles() -> [CSSStyleSheet]
}

public extension Array where Element == any WebComponent {
    func gathered_styles() -> [CSSStyleSheet] {
        var out: [CSSStyleSheet] = []
        for c in self {
            out.append(contentsOf: c.styles())
        }
        return out
    }
}
