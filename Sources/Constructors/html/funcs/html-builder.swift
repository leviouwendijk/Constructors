import Foundation

@resultBuilder
public enum HTMLBuilder: Sendable {
    public static func buildBlock(_ parts: [any HTMLNode]...) -> [any HTMLNode] {
        parts.flatMap { $0 }
    }
    public static func buildArray(_ parts: [[any HTMLNode]]) -> [any HTMLNode] { parts.flatMap { $0 } }
    public static func buildEither(first: [any HTMLNode]) -> [any HTMLNode] { first }
    public static func buildEither(second: [any HTMLNode]) -> [any HTMLNode] { second }
    public static func buildOptional(_ part: [any HTMLNode]?) -> [any HTMLNode] { part ?? [] }
    public static func buildExpression(_ node: any HTMLNode) -> [any HTMLNode] { [node] }
    public static func buildExpression(_ nodes: [any HTMLNode]) -> [any HTMLNode] { nodes }
    public static func buildExpression(_ text: String) -> [any HTMLNode] { [HTMLText(text)] }
    public static func buildLimitedAvailability(_ part: [any HTMLNode]) -> [any HTMLNode] { part }
}
