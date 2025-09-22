import Foundation

public struct HTMLRaw: HTMLNode {
    public let html: String

    public init(_ html: String) { self.html = html }

    public func render(pretty: Bool, indent: Int, indentStep: Int) -> String {
        guard pretty else { return html }
        let pad = String(repeating: " ", count: indent)
        return html
        .split(separator: "\n", omittingEmptySubsequences: false)
        .map { pad + String($0) }
        .joined(separator: "\n") + "\n"
    }
}
