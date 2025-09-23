import Foundation

public struct HTMLAttribute: ExpressibleByDictionaryLiteral, Sendable {
    private var storage: [(String, String?)] = []

    public init() {}

    public init(dictionaryLiteral elements: (String, String)...) {
        self.storage = elements.map { ($0.0, $0.1) }
    }

    public static func id(_ value: String) -> HTMLAttribute { ["id": value] }

    public static func `class`(_ classes: [String]) -> HTMLAttribute { ["class": classes.joined(separator: " ")] }

    public static func data(_ key: String, _ value: String) -> HTMLAttribute { ["data-\(key)": value] }

    public static func aria(_ key: String, _ value: String) -> HTMLAttribute { ["aria-\(key)": value] }

    public static func bool(_ key: String, _ enabled: Bool) -> HTMLAttribute {
        var a = HTMLAttribute()
        if enabled { a.storage.append((key, nil)) }
        return a
    }

    public mutating func merge(_ other: HTMLAttribute) {
        storage.append(contentsOf: other.storage)
    }

    public func render() -> String {
        guard !storage.isEmpty else { return "" }

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

        let ordered = storage.sorted { (a, b) in
            let (ra, sa) = keyRank(a.0)
            let (rb, sb) = keyRank(b.0)
            return (ra, sa) < (rb, sb)
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
}
