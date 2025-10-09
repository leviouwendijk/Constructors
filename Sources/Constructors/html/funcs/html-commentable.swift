import Foundation

public protocol HTMLCommentable {
    func commented(
        options: HTMLRenderOptions,
        indent: Int
    ) -> any HTMLNode
}

public extension HTMLCommentable {
    func commented(
        node: any HTMLNode,
        options: HTMLRenderOptions = .init(),
        indent: Int = 0
    ) -> any HTMLNode {
        let rendered = node.render(options: options, indent: indent)
            .trimmingSingleTrailingNewline()
        return HTML.comment(sanitizeForHtmlComment(rendered))
    }
}
