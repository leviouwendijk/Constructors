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
public func demarcation_comment(
    id: String?,
    prefix: String,
    allow: Set<BuildEnvironment> = []
) -> any HTMLNode {
    var pre = prefix

    if let id {
        let str = ": \(id)"
        pre.append(str)
    }

    if !allow.isEmpty {
        pre.append("\(allow.map { $0.rawValue } )")
    }

    return HTML.prefixedComment(pre)
}

@inlinable
public func demarcation_comment_end(
    id: String?,
    prefix: String = "end",
) -> any HTMLNode {
    return demarcation_comment(id: id, prefix: prefix)
}

@inlinable
public func demarcate_html_node(
    id: String?,
    body: [any HTMLNode],
    prefix: String,
    suffix: String? = nil,
    allow: Set<BuildEnvironment> = []
) -> [any HTMLNode] {
    let demarc_start: any HTMLNode = demarcation_comment(
        id: id, 
        prefix: prefix,
        allow: allow
    )
    let demarc_end: any HTMLNode

    if let suffix {
        demarc_end = demarcation_comment_end(id: id, prefix: suffix)
    } else {
        demarc_end = demarcation_comment_end(id: id)
    }

    return demarc_start + body + demarc_end
}

@inlinable
public func experimental(
    id: String? = nil,
    allow: Set<BuildEnvironment> = [.local, .test],
    @HTMLBuilder _ body: () -> [any HTMLNode]
) -> any HTMLNode {
    let demarcated_body = demarcate_html_node(
        id: id,
        body: body(),
        prefix: "experimental",
        allow: allow
    )
    // return HTMLGate(id: id, allow: allow, children: body())
    return HTMLGate(id: id, allow: allow, children: demarcated_body)
}

@inlinable
public func scoped(
    id: String? = nil,
    allow: Set<BuildEnvironment> = [.local, .test],
    @HTMLBuilder _ body: () -> [any HTMLNode]
) -> any HTMLNode {
    let demarcated_body = demarcate_html_node(
        id: id,
        body: body(),
        prefix: "scoped",
        allow: allow
    )

    // return HTMLGate(id: id, allow: allow, children: body())
    return HTMLGate(id: id, allow: allow, children: demarcated_body)
}

@inlinable
public func onlyPublic(
    id: String? = nil,
    @HTMLBuilder _ body: () -> [any HTMLNode]
) -> any HTMLNode {
    let demarcated_body = demarcate_html_node(
        id: id,
        body: body(),
        prefix: "onlyPublic",
        allow: [.public]
    )

    // return experimental(id: id, allow: [.public], body)
    return HTMLGate(id: id, allow: [.public], children: demarcated_body)
}

@inlinable
public func onlyTest(
    id: String? = nil,
    @HTMLBuilder _ body: () -> [any HTMLNode]
) -> any HTMLNode {
    let demarcated_body = demarcate_html_node(
        id: id,
        body: body(),
        prefix: "onlyTest",
        allow: [.test]
    )
    // experimental(id: id, allow: [.test], body)
    return HTMLGate(id: id, allow: [.test], children: demarcated_body)
}

@inlinable
public func notPublic(
    id: String? = nil,
    @HTMLBuilder _ body: () -> [any HTMLNode]
) -> any HTMLNode {
    var cases: Set<BuildEnvironment> = Set(BuildEnvironment.allCases)
    cases.remove(.public)

    let demarcated_body = demarcate_html_node(
        id: id,
        body: body(),
        prefix: "notPublic",
        allow: cases
    )
    // return experimental(id: id, allow: [.local, .test], body)
    return HTMLGate(id: id, allow: cases, children: demarcated_body)
}
