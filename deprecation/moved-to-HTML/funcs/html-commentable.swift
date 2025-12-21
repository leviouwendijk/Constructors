import Foundation

public protocol HTMLCommentable {
    func commented(
        options: HTMLRenderOptions,
        indent: Int
    ) -> any HTMLNode
}

// public extension HTMLCommentable {
//     func commented(
//         node: any HTMLNode,
//         options: HTMLRenderOptions = .init(indentation: false, newlineSeparated: false, ensureTrailingNewline: false),
//         indent: Int = 0
//     ) -> any HTMLNode {
//         let rendered = node.render(options: options, indent: indent)
//             .trimmingSingleTrailingNewline()
//         return HTML.comment(sanitizeForHtmlComment(rendered))
//     }
// }

public extension HTMLCommentable where Self: HTMLNode {
    func commented(
        options: HTMLRenderOptions = .init(
            indentation: false,
            newlineSeparated: false,
            ensureTrailingNewline: false
        ),
        indent: Int = 0
    ) -> any HTMLNode {
        let rendered = self
            .render(options: options, indent: indent)
            .trimmingSingleTrailingNewline()
        return HTML.comment(sanitizeForHtmlComment(rendered))
    }
}
