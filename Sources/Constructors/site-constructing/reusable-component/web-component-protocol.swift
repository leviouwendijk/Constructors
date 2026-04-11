import CSS
import HTML

// backwards compatibility
@available(*, message: "stop using WebComponent because redundant 1:1 to ReusableComponent")
public typealias WebComponent = ReusableComponent


// public protocol WebComponent: ReusableComponent {
//     // func html() -> HTMLFragment
//     // func styles() -> [CSSStyleSheet]
// }

// public extension Array where Element == any WebComponent {
//     func gathered_styles() -> [CSSStyleSheet] {
//         var out: [CSSStyleSheet] = []
//         for c in self {
//             out.append(contentsOf: c.styles())
//         }
//         return out
//     }
// }
