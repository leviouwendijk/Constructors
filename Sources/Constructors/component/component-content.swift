import HTML

/// Terminal HTML content authored by one component.
///
/// This value contains representation-level HTML only. Dependency identity and
/// site-reference semantics remain separate values so they can be inspected,
/// composed, resolved, and projected before any later serialization.
public struct ComponentContent:
    Sendable
{
    public let head:
        HTMLFragment

    public let body:
        HTMLFragment

    public init(
        head:
            HTMLFragment = [],
        body:
            HTMLFragment = []
    ) {
        self.head =
            head

        self.body =
            body
    }

    public static var empty:
        ComponentContent
    {
        ComponentContent()
    }

    public func merging(
        _ other:
            ComponentContent
    ) -> ComponentContent {
        ComponentContent(
            head:
                head
                + other.head,
            body:
                body
                + other.body
        )
    }
}
