import Foundation

public struct HTMLRaw: HTMLNode {
    public let html: String

    public init(_ html: String) { self.html = html }

    public func render(options: HTMLRenderOptions, indent: Int) -> String {
        // guard options.pretty else { return html }
        // // let space = " "
        // // let indentation = String(repeating: space, count: (indent * options.indentStep))

        // let pad = String(repeating: " ", count: indent)

        // return html
        //     .split(separator: "\n", omittingEmptySubsequences: false)
        //     .map { pad + String($0) }
        //     .joined(separator: "\n") + "\n"

        let pad = options.indentation ? String(repeating: " ", count: indent) : ""
        if !options.newlineSeparated { return pad + html }
        var out = html
            .split(separator: "\n", omittingEmptySubsequences: false)
            .map { pad + String($0) }
            .joined(separator: "\n")
        if options.ensureTrailingNewline { out.append("\n") }
        return out
    }
}
