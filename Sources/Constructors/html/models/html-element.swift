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

    // public func render(pretty: Bool, indent: Int, indentStep: Int) -> String {
    //     let pad = pretty ? String(repeating: " ", count: indent) : ""
    //     let nl  = pretty ? "\n" : ""
    //     let attrStr = attrs.render()
    //     let open = attrStr.isEmpty ? "<\(tag)>" : "<\(tag) \(attrStr)>"

    //     if HTMLVoidTags.contains(tag) {
    //         // Void elements: <meta ...>, <img ...>, <br>, <hr>, <input>, <link>, etc.
    //         return pretty ? pad + open + nl : open
    //     }

    //     if children.isEmpty {
    //         // <div></div> or <span></span>
    //         if selfClosing && !HTMLVoidTags.contains(tag) {
    //             return pretty ? pad + open.dropLast() + "/>\n" : open.dropLast() + "/>"
    //         }

    //         return pretty ? pad + open + "</\(tag)>" + nl : open + "</\(tag)>"
    //     }

    //     if pretty {
    //         let inner = children.map { $0.render(pretty: true, indent: indent + indentStep, indentStep: indentStep) }.joined()
    //         return "\(pad)\(open)\n\(inner)\(pad)</\(tag)>\n"
    //     } else {
    //         let inner = children.map { $0.render(pretty: false, indent: 0, indentStep: indentStep) }.joined()
    //         return "\(open)\(inner)</\(tag)>"
    //     }
    // }

//     public func render(pretty: Bool, indent: Int, indentStep: Int) -> String {
//         let pad = pretty ? String(repeating: " ", count: indent) : ""
//         let nl  = pretty ? "\n" : ""
//         let attrStr = attrs.render()
//         let open = attrStr.isEmpty ? "<\(tag)>" : "<\(tag) \(attrStr)>"

//         // HTML void elements
//         if HTMLVoidTags.contains(tag) {
//             return pretty ? pad + open + nl : open
//         }

//         // No children
//         if children.isEmpty {
//             if selfClosing {
//                 let selfClosed = String(open.dropLast()) + "/>"
//                 return pretty ? pad + selfClosed + nl : selfClosed
//             }
//             return pretty ? pad + open + "</\(tag)>" + nl : open + "</\(tag)>"
//         }

//         // With children
//         if pretty {
//             let inner = children.map { $0.render(pretty: true, indent: indent + indentStep, indentStep: indentStep) }.joined()
//             return "\(pad)\(open)\n\(inner)\(pad)</\(tag)>\n"
//         } else {
//             let inner = children.map { $0.render(pretty: false, indent: indent, indentStep: indentStep) }.joined()
//             return "\(open)\(inner)</\(tag)>"
//         }
//     }

    // Helper to render empty nodes (void or selfClosing)
    @inline(__always)
    private func renderEmpty(open: String, indent: Int, options: HTMLRenderOptions) -> String {
        let pad = options.pretty ? String(repeating: " ", count: indent) : ""
        let nl  = options.pretty ? "\n" : ""

        if HTMLSpec.isVoid(tag) {
            return options.pretty ? pad + open + nl : open
        }
        if selfClosing {
            let selfClosed = String(open.dropLast()) + "/>"
            return options.pretty ? pad + selfClosed + nl : selfClosed
        }
        // Not void and not selfClosing → caller will append closing tag
        return "" // signal “not handled”
    }

    public func render(options: HTMLRenderOptions, indent: Int) -> String {
        let pad = options.pretty ? String(repeating: " ", count: indent) : ""
        let nl  = options.pretty ? "\n" : ""

        let attrStr = attrs.render(order: options.attributeOrder)
        let open = attrStr.isEmpty ? "<\(tag)>" : "<\(tag) \(attrStr)>"

        // Empty cases first
        if children.isEmpty {
            // try void/selfClosing paths
            let empty = renderEmpty(open: open, indent: indent, options: options)
            if !empty.isEmpty { return empty }
            // fallback: explicit open/close
            return options.pretty ? pad + open + "</\(tag)>" + nl : open + "</\(tag)>"
        }

        // With children
        if options.pretty {
            let inner = children.map { $0.render(options: options, indent: indent + options.indentStep) }.joined()
            return "\(pad)\(open)\n\(inner)\(pad)</\(tag)>\n"
        } else {
            let inner = children.map { $0.render(options: options, indent: indent) }.joined()
            return "\(open)\(inner)</\(tag)>"
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
