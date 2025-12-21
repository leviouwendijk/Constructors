import Foundation

public struct HTMLAttribute: ExpressibleByDictionaryLiteral, Sendable {
    private var storage: [(String, String?)] = []

    public init() {}

    public init(dictionaryLiteral elements: (String, String)...) {
        self.storage = elements.map { ($0.0, $0.1) }
    }

    // public init(_ elements: [String: String]) {
    //     self.storage = elements.map { ($0.0, $0.1) }
    // }

    public static func id(_ value: String) -> HTMLAttribute { ["id": value] }
    public static func `class`(_ classes: [String]) -> HTMLAttribute { ["class": classes.joined(separator: " ")] }
    public static func data(_ key: String, _ value: String) -> HTMLAttribute { ["data-\(key)": value] }
    public static func aria(_ key: String, _ value: String) -> HTMLAttribute { ["aria-\(key)": value] }
    public static func bool(_ key: String, _ enabled: Bool) -> HTMLAttribute {
        var a = HTMLAttribute()
        if enabled { a.storage.append((key, nil)) }
        return a
    }

    public static func type(_ value: String) -> HTMLAttribute { ["type": value] }
    public static func href(_ value: String) -> HTMLAttribute { ["href": value] }

    public mutating func merge(_ other: HTMLAttribute) {
        storage.append(contentsOf: other.storage)
    }

    /// Back-compat: existing API keeps "ranked" as default behavior.
    public func render() -> String {
        render(order: .ranked)
    }

    /// Order-aware rendering. `.ranked` preserves the old implementation.
    public func render(order: HTMLAttributeOrder) -> String {
        guard !storage.isEmpty else { return "" }

        let ordered: [(String, String?)]

        switch order {
        case .preserve:
            ordered = storage

        case .ranked:
            // Original behavior (unchanged)
            @inline(__always)
            func keyRank(_ k: String) -> (Int, String) {
                // 0 = highest priority, larger = lower
                switch k {
                case "id": return (0, k)
                case "class": return (1, k)
                case "src": return (2, k)
                case "href": return (3, k)
                case "alt": return (4, k)
                case "type": return (5, k)
                case "name": return (6, k)
                case "value": return (7, k)
                case "width": return (8, k)
                case "height": return (9, k)
                case "style": return (10, k)
                default:
                    if k.hasPrefix("data-") { return (20, k) }
                    if k.hasPrefix("aria-") { return (30, k) }
                    return (40, k)
                }
            }

            ordered = storage.sorted { (a, b) in
                let (ra, sa) = keyRank(a.0)
                let (rb, sb) = keyRank(b.0)
                return (ra, sa) < (rb, sb)
            }

        case .custom(let cmp):
            // Deterministic: if keys are equal, keep insertion order.
            let enumerated = Array(storage.enumerated())
            let sorted = enumerated.sorted { lhs, rhs in
                let lk = lhs.element.0
                let rk = rhs.element.0
                if lk == rk { return lhs.offset < rhs.offset }
                return cmp(lk, rk)
            }
            ordered = sorted.map { $0.element }
        }

        var parts: [String] = []
        parts.reserveCapacity(ordered.count)
        for (k, v) in ordered {
            if let v {
                parts.append("\(k)=\"\(htmlEscape(v))\"")
            } else {
                parts.append(k)
            }
        }
        return parts.joined(separator: " ")
    }

    public static func `class`(_ s: String) -> HTMLAttribute { ["class": s] }
}

// extension HTMLAttribute {
//     public static func style(_ css: String) -> HTMLAttribute {
//         ["style": css]
//     }

//     public static func style(_ declarations: [CSSDeclaration]) -> HTMLAttribute {
//         ["style": declarations.renderInline()]
//     }

//     public static func style(_ declarations: CSSDeclaration...) -> HTMLAttribute {
//         .style(declarations)
//     }

//     public static func style(@CSSDeclBuilder _ c: () -> [CSSDeclaration]) -> HTMLAttribute {
//         .style(c())
//     }
// }

extension HTMLAttribute {
    /// Return the last value for a given attribute key, if any.
    public func value(for key: String) -> String? {
        for (k, v) in storage.reversed() where k == key {
            return v ?? ""
        }
        return nil
    }

    /// Convenience: split the `class` attribute into individual class names.
    public var classList: [String] {
        guard let raw = value(for: "class") else { return [] }
        return raw
            .split(whereSeparator: { $0 == " " || $0 == "\t" || $0 == "\n" || $0 == "\r" })
            .map(String.init)
            .filter { !$0.isEmpty }
    }
}
