import Foundation

public struct HTMLComment: HTMLNode {
    public let text: String
    public func render(pretty: Bool, indent: Int, indentStep: Int) -> String {
        let pad = pretty ? String(repeating: " ", count: indent) : ""
        return pretty ? "\(pad)<!-- \(text) -->\n" : "<!-- \(text) -->"
    }
}
