import Foundation

public struct CSSMetaSection<Item: CSSNode>: Sendable, Equatable {
    /// Optional machine-friendly id (for tooling / lookups).
    public var id: String?
    /// Human-facing title, e.g. "Landing / Review Tokens".
    public var title: String
    /// Optional longer description for docs / palette views.
    public var description: String?
    /// The underlying CSS nodes, e.g. `[CSSRule]` or `[CSSMedia]`.
    public var items: [Item]

    public init(
        id: String? = nil,
        title: String,
        description: String? = nil,
        items: [Item]
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.items = items
    }
}

extension Array where Element: CSSNode {
    public func metasection(
        _ title: String,
        id: String? = nil,
        description: String? = nil
    ) -> CSSMetaSection<Element> {
        .init(
            id: id,
            title: title,
            description: description,
            items: self
        )
    }
}
