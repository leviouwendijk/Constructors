import Foundation

/// Simple view of a CSS custom property (`--foo`) pulled from a stylesheet.
public struct CSSCustomProperty: Sendable, Equatable {
    /// Selector this declaration came from (often `:root`).
    public var selector: String
    /// Custom property name, e.g. `"--bg"`.
    public var name: String
    /// Raw value from CSS, e.g. `"#ffffff"` or `"var(--gray-500)"`.
    public var value: String

    public init(
        selector: String,
        name: String,
        value: String
    ) {
        self.selector = selector
        self.name = name
        self.value = value
    }
}

@inline(__always)
internal func _extractCustomCSSProperties(
    from rules: [CSSRule],
    selector: String,
    filter: ((CSSCustomProperty) -> Bool)?
) -> [CSSCustomProperty] {
    let rulesToScan = rules.filter { $0.selector == selector }

    var out: [CSSCustomProperty] = []
    out.reserveCapacity(
        rulesToScan.reduce(0) { $0 + $1.declarations.count }
    )

    for rule in rulesToScan {
        for decl in rule.declarations {
            guard decl.property.hasPrefix("--") else { continue }

            let token = CSSCustomProperty(
                selector: rule.selector,
                name: decl.property,
                value: decl.value
            )

            if let filter, !filter(token) {
                continue
            }

            out.append(token)
        }
    }

    return out
}
