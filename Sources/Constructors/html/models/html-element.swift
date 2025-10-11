import Foundation

public struct HTMLElement: HTMLNode {
    public let tag: String
    public var attrs: HTMLAttribute
    public var children: [any HTMLNode]
    public var selfClosing: Bool // NEW

    public init(
        _ tag: String,
        attrs: HTMLAttribute = HTMLAttribute(),
        children: [any HTMLNode] = [],
        selfClosing: Bool = false
    ) {
        self.tag = tag
        self.attrs = attrs
        self.children = children
        self.selfClosing = selfClosing
    }

    @inline(__always)
    private func renderEmpty(open: String, indent: Int, options: HTMLRenderOptions) -> String {
        let pad = options.indentation ? String(repeating: " ", count: indent) : ""
        let nl  = (options.ensureTrailingNewline && options.newlineSeparated)  ? "\n" : ""

        if HTMLSpec.isVoid(tag) {
            return options.indentation ? pad + open + nl : open
        }
        if selfClosing {
            let selfClosed = String(open.dropLast()) + "/>"
            return options.indentation ? pad + selfClosed + nl : selfClosed
        }
        // Not void and not selfClosing → caller will append closing tag
        return "" // signal “not handled”
    }

    public func render(options: HTMLRenderOptions, indent: Int) -> String {
        let pad = options.indentation ? String(repeating: " ", count: indent) : ""
        let nl  = options.newlineSeparated ? "\n" : ""

        let attrStr = attrs.render(order: options.attributeOrder)
        let open = attrStr.isEmpty ? "<\(tag)>" : "<\(tag) \(attrStr)>"

        // Empty cases first
        if children.isEmpty {
            // try void/selfClosing paths
            let empty = renderEmpty(open: open, indent: indent, options: options)
            if !empty.isEmpty { return empty }
            // fallback: explicit open/close
            // return options.pretty ? pad + open + "</\(tag)>" + nl : open + "</\(tag)>"
            let body = "\(pad)\(open)</\(tag)>"
            return options.ensureTrailingNewline ? (body + nl) : body
        }

        // With children
        if options.newlineSeparated {
            let childIndent = indent + options.indentStep
            let inner = children.map { $0.render(options: options, indent: childIndent) }.joined()
            let pad2 = options.indentation ? String(repeating: " ", count: childIndent) : ""
            // Ensure first inner line is padded even if the first child didn’t add it
            let innerIndented = (options.indentation && !inner.hasPrefix(pad2)) ? (pad2 + inner) : inner
            let innerWithTerminatingNewline = innerIndented.hasSuffix("\n") ? innerIndented : (innerIndented + "\n")
            let body = "\(pad)\(open)\n\(innerWithTerminatingNewline)\(pad)</\(tag)>"
            return options.ensureTrailingNewline ? (body + "\n") : body
        } else {
            // Single-line inner content; still respect indentation for first inner line
            let childIndent = indent + options.indentStep
            let inner = children.map { $0.render(options: options, indent: childIndent) }.joined()
            let pad2 = options.indentation ? String(repeating: " ", count: childIndent) : ""
            let body = "\(pad)\(open)\(options.indentation ? pad2 : "")\(inner)\(options.indentation ? pad : "")</\(tag)>"
            return options.ensureTrailingNewline ? (body + nl) : body
        }
    }

    public func render(pretty: Bool, indent: Int, indentStep: Int) -> String {
        let legacy = HTMLRenderOptions(
            pretty: pretty,
            indentStep: indentStep,
            attributeOrder: .ranked,
            ensureTrailingNewline: false
        )
        return render(options: legacy, indent: indent)
    }
}
