import Foundation

public struct CSSMedia: Sendable, Equatable, CSSNode {
    public var query: String          // e.g. "(prefers-color-scheme: dark)"
    public var rules: [CSSRule]

    public init(query: String, rules: [CSSRule]) {
        self.query = query
        self.rules = rules
    }
}

public typealias CSSMediaMetaSection = CSSMetaSection<CSSMedia>
