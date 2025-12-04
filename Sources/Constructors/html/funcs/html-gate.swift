import Foundation

public struct HTMLGate: HTMLNode {
    let id: String?
    let allowed: Set<BuildEnvironment>
    let children: [any HTMLNode]

    public init(
        id: String? = nil,
        allow allowed: Set<BuildEnvironment>,
        children: [any HTMLNode]
    ) {
        self.id = id
        self.allowed = allowed
        self.children = children
    }

    public func render(
        options: HTMLRenderOptions,
        indent: Int
    ) -> String {
        let ok = allowed.contains(options.environment)
        options.onGate?(
            GateEvent(id: id, allowed: allowed, environment: options.environment, rendered: ok)
        )
        guard ok else { return "" }
        return children.map { $0.render(options: options, indent: indent) }.joined()
    }
}

@inlinable
public func experimental(
    id: String? = nil,
    allow: Set<BuildEnvironment> = [.local, .test],
    @HTMLBuilder _ body: () -> [any HTMLNode]
) -> any HTMLNode {
    let prependable_el = HTML.prefixedComment("experimental")
    let combined_body = prependable_el + body()
    // return HTMLGate(id: id, allow: allow, children: body())
    return HTMLGate(id: id, allow: allow, children: combined_body)
}

@inlinable
public func scoped(
    id: String? = nil,
    allow: Set<BuildEnvironment> = [.local, .test],
    @HTMLBuilder _ body: () -> [any HTMLNode]
) -> any HTMLNode {
    HTMLGate(id: id, allow: allow, children: body())
}

@inlinable
public func onlyPublic(
    id: String? = nil,
    @HTMLBuilder _ body: () -> [any HTMLNode]
) -> any HTMLNode {
    experimental(id: id, allow: [.public], body)
}

@inlinable
public func onlyTest(
    id: String? = nil,
    @HTMLBuilder _ body: () -> [any HTMLNode]
) -> any HTMLNode {
    experimental(id: id, allow: [.test], body)
}

@inlinable
public func notPublic(
    id: String? = nil,
    @HTMLBuilder _ body: () -> [any HTMLNode]
) -> any HTMLNode {
    experimental(id: id, allow: [.local, .test], body)
}
