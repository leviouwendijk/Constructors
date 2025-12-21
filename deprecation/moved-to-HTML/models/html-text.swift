import Foundation

public struct HTMLText: HTMLNode {
    public let text: String

    public init(_ text: String) { self.text = text }

    @available(*, message: "deprecated")
    public func render(pretty: Bool, indent: Int, indentStep: Int) -> String {
        let escaped = htmlEscape(text)
        guard pretty else { return escaped }
        let pad = String(repeating: " ", count: indent)
        return escaped
        .split(separator: "\n", omittingEmptySubsequences: false)
        .map { pad + String($0) }
        .joined(separator: "\n") + "\n"
    }

    public func render(options: HTMLRenderOptions, indent: Int) -> String {
        let escaped = htmlEscape(text)
        let pad = options.indentation ? String(repeating: " ", count: indent) : ""

        if !options.newlineSeparated {
            return pad + escaped
        }
        var out = escaped
            .split(separator: "\n", omittingEmptySubsequences: false)
            .map { pad + String($0) }
            .joined(separator: "\n")
        if options.ensureTrailingNewline { out.append("\n") }
        return out
    }
}
