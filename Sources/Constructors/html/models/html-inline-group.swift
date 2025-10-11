import Foundation

struct HTMLInlineGroup: HTMLNode {
    let children: [any HTMLNode]

    init(_ children: [any HTMLNode]) { self.children = children }

    func render(options: HTMLRenderOptions, indent: Int) -> String {
        var tight = options
        tight.indentation = false
        tight.newlineSeparated = false
        tight.ensureTrailingNewline = true
        return children.map { $0.render(options: tight, indent: indent) }.joined()
    }
}
