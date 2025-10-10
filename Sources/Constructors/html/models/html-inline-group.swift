import Foundation

struct HTMLInlineGroup: HTMLNode {
    let children: [any HTMLNode]

    init(_ children: [any HTMLNode]) { self.children = children }

    func render(options: HTMLRenderOptions, indent: Int) -> String {
        // Render children compactly (no pretty newlines/indent between them)
        var tight = options
        // tight.pretty = false
        // return children.map { $0.render(options: tight, indent: indent) }.joined()

        // Keep indentation; disable internal newlines and trailing newline.
        tight.newlineSeparated = false
        tight.ensureTrailingNewline = false
        // Indentation stays true so the parent can pad the first inner line.
        return children.map { $0.render(options: tight, indent: indent) }.joined()
    }
}
