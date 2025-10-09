import Foundation

public struct HTMLNewline: HTMLNode {
    public let count: Int
    public init(_ count: Int = 1) { self.count = count }

    public func render(pretty: Bool, indent: Int, indentStep: Int) -> String {
        // Only meaningful in pretty mode; keep minified output tight
        guard pretty else { return "" }
        return String(repeating: "\n", count: count)
    }
}
