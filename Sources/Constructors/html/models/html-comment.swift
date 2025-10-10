import Foundation

public struct HTMLComment: HTMLNode {
    public let text: String

    public func render(options: HTMLRenderOptions, indent: Int) -> String {
        // let space = " "
        // let indentation = String(repeating: space, count: (indent * options.indentStep))
        // let indentation = String(repeating: " ", count: indent)
        // let pad = options.pretty ? indentation : ""
        // let newline  = options.pretty ? "\n" : ""

        // return "\(pad)<!-- \(text) -->\(newline)"
        let pad = options.indentation ? String(repeating: " ", count: indent) : ""
        let nl  = (options.ensureTrailingNewline && options.newlineSeparated) ? "\n" : ""
        return "\(pad)<!-- \(text) -->\(nl)"
    }
}
