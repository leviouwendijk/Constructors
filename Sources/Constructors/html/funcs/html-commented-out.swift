import Foundation

@inline(__always)
private func sanitizeForHtmlComment(_ s: String) -> String {
    // HTML comments must not contain "--" anywhere.
    // Replace with an em dash to keep it visibly similar but valid.
    s.replacingOccurrences(of: "--", with: "—")
}

private extension String {
    func trimmingSingleTrailingNewline() -> String {
        guard last == "\n" else { return self }
        return String(dropLast(1))
    }
}

public extension HTML {
    /// Renders `node` with the given options and wraps the result in an HTML comment.
    /// - Parameters:
    ///   - node: Any HTMLNode to be commented out.
    ///   - options: Render options (pretty/indent/order). Defaults to your global defaults.
    ///   - indent: Starting indent (spaces) for the comment line(s).
    /// - Returns: `<!-- ...render(node)... -->`
    static func commentedOut(
        _ node: any HTMLNode,
        options: HTMLRenderOptions = .init(),
        indent: Int = 0
    ) -> any HTMLNode {
        let rendered = node.render(options: options, indent: indent)
            .trimmingSingleTrailingNewline()
        return HTML.comment(sanitizeForHtmlComment(rendered))
    }

    /// Builder variant: render multiple nodes, join them, and wrap in a single comment block.
    static func commentedOut(
        options: HTMLRenderOptions = .init(),
        indent: Int = 0,
        @HTMLBuilder _ content: () -> [any HTMLNode]
    ) -> any HTMLNode {
        let joined = content()
            .map { $0.render(options: options, indent: indent) }
            .joined()
            .trimmingSingleTrailingNewline()
        return HTML.comment(sanitizeForHtmlComment(joined))
    }
}
