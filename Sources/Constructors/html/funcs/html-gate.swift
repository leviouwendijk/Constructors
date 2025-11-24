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
    HTMLGate(id: id, allow: allow, children: body())
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

// public struct HTMLGate: HTMLNode {
//     let allowed: Set<BuildEnvironment>
//     let children: [any HTMLNode]

//     public init(allow allowed: Set<BuildEnvironment>, children: [any HTMLNode]) {
//         self.allowed = allowed
//         self.children = children
//     }

//     public func render(options: HTMLRenderOptions, indent: Int) -> String {
//         guard allowed.contains(options.environment) else { return "" }
//         // Render children with the same options/indent (standard pattern in your nodes).
//         return children.map { $0.render(options: options, indent: indent) }.joined()
//     }
// }

// @inlinable
// public func experimental(
//     allow: Set<BuildEnvironment> = [.local, .test],
//     @HTMLBuilder _ body: () -> [any HTMLNode]
// ) -> any HTMLNode {
//     HTMLGate(allow: allow, children: body())
// }

// @inlinable public func onlyPublic(@HTMLBuilder _ body: () -> [any HTMLNode]) -> any HTMLNode {
//     experimental(allow: [.public], body)
// }
// @inlinable public func onlyTest(@HTMLBuilder _ body: () -> [any HTMLNode]) -> any HTMLNode {
//     experimental(allow: [.test], body)
// }
// @inlinable public func notPublic(@HTMLBuilder _ body: () -> [any HTMLNode]) -> any HTMLNode {
//     experimental(allow: [.local, .test], body)
// }

