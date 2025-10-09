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
        guard options.pretty else { return escaped }
        // let space = " "
        // let indentation = String(repeating: space, count: (indent * options.indentStep))
        let pad = String(repeating: " ", count: indent)

        return escaped
            .split(separator: "\n", omittingEmptySubsequences: false)
            .map { pad + String($0) }
            .joined(separator: "\n") + "\n"
    }
}
