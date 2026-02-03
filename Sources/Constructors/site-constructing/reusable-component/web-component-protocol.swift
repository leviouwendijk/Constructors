import CSS
import HTML

// backwards compatibility
public protocol WebComponent: ReusableComponent {
    // func html() -> HTMLFragment
    // func styles() -> [CSSStyleSheet]
}

// public extension Array where Element == any WebComponent {
//     func gathered_styles() -> [CSSStyleSheet] {
//         var out: [CSSStyleSheet] = []
//         for c in self {
//             out.append(contentsOf: c.styles())
//         }
//         return out
//     }
// }
