import Foundation

public struct HTMLElement: HTMLNode {
    public let tag: String
    public var attrs: HTMLAttribute
    public var children: [any HTMLNode]

    public init(_ tag: String, attrs: HTMLAttribute = HTMLAttribute(), children: [any HTMLNode] = []) {
        self.tag = tag
        self.attrs = attrs
        self.children = children
    }

    public func _render(pretty: Bool, indent: Int, indentStep: Int) -> String {
        let pad = pretty ? String(repeating: " ", count: indent) : ""
        let nl  = pretty ? "\n" : ""
        let attrStr = attrs.render()
        let open = attrStr.isEmpty ? "<\(tag)>" : "<\(tag) \(attrStr)>"

        if HTMLVoidTags.contains(tag) {
            // Void elements: <meta ...>, <img ...>, <br>, <hr>, <input>, <link>, etc.
            return pretty ? pad + open + nl : open
        }

        if children.isEmpty {
            // <div></div> or <span></span>
            return pretty ? pad + open + "</\(tag)>" + nl : open + "</\(tag)>"
        }

        if pretty {
            let inner = children.map { $0._render(pretty: true, indent: indent + indentStep, indentStep: indentStep) }.joined()
            return "\(pad)\(open)\n\(inner)\(pad)</\(tag)>\n"
        } else {
            let inner = children.map { $0._render(pretty: false, indent: 0, indentStep: indentStep) }.joined()
            return "\(open)\(inner)</\(tag)>"
        }
    }
}
