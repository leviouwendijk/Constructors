import Foundation

struct HTMLInlineGroup: HTMLNode {
    let children: [any HTMLNode]

    init(_ children: [any HTMLNode]) { self.children = children }

    func render(options: HTMLRenderOptions, indent: Int) -> String {
        // Render children compactly (no pretty newlines/indent between them)
        var tight = options
        tight.pretty = false
        return children.map { $0.render(options: tight, indent: indent) }.joined()
    }
}
