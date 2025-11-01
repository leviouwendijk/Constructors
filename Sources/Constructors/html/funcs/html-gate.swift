import Foundation

public struct HTMLGate: HTMLNode {
    let allowed: Set<BuildEnvironment>
    let children: [any HTMLNode]

    public init(allow allowed: Set<BuildEnvironment>, children: [any HTMLNode]) {
        self.allowed = allowed
        self.children = children
    }

    public func render(options: HTMLRenderOptions, indent: Int) -> String {
        guard allowed.contains(options.environment) else { return "" }
        // Render children with the same options/indent (standard pattern in your nodes).
        return children.map { $0.render(options: options, indent: indent) }.joined()
    }
}
