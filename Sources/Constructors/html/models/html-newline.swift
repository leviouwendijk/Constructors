import Foundation

public struct HTMLNewline: HTMLNode {
    public let count: Int
    public init(_ count: Int = 1) { self.count = count }

    public func render(options: HTMLRenderOptions, indent: Int) -> String {
        // Only meaningful in pretty mode; keep minified output tight
        // guard options.pretty else { return "" }
        // return String(repeating: "\n", count: count)
        guard options.newlineSeparated else { return "" }
        return options.ensureTrailingNewline ? String(repeating: "\n", count: count) : ""
    }
}
