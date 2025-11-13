import Foundation

public struct CSSSelector: Sendable, Equatable {
    public var raw: String

    public init(_ raw: String) {
        self.raw = raw
    }
}

public extension CSSSelector {
    // Basic selectors
    static func element(_ name: String) -> CSSSelector {
        CSSSelector(name)
    }

    static func `class`(_ name: String) -> CSSSelector {
        CSSSelector(".\(name)")
    }

    static func id(_ name: String) -> CSSSelector {
        CSSSelector("#\(name)")
    }

    /// Arbitrary raw selector when you really need it.
    static func raw(_ value: String) -> CSSSelector {
        CSSSelector(value)
    }

    // Pseudo classes/elements

    func pseudoClass(_ name: String) -> CSSSelector {
        CSSSelector("\(raw):\(name)")
    }

    func pseudoElement(_ name: String) -> CSSSelector {
        CSSSelector("\(raw)::\(name)")
    }

    // Combinators

    func descendant(_ other: CSSSelector) -> CSSSelector {
        CSSSelector("\(raw) \(other.raw)")
    }

    func child(_ other: CSSSelector) -> CSSSelector {
        CSSSelector("\(raw) > \(other.raw)")
    }

    func adjacentSibling(_ other: CSSSelector) -> CSSSelector {
        CSSSelector("\(raw) + \(other.raw)")
    }

    func generalSibling(_ other: CSSSelector) -> CSSSelector {
        CSSSelector("\(raw) ~ \(other.raw)")
    }
}
