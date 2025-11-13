import Foundation

@resultBuilder
public enum ICSBuilder {
    public static func buildBlock(_ parts: [any ICSNode]...) -> [any ICSNode] {
        parts.flatMap { $0 }
    }

    public static func buildArray(_ parts: [[any ICSNode]]) -> [any ICSNode] { parts.flatMap { $0 } }
    public static func buildEither(first: [any ICSNode]) -> [any ICSNode] { first }
    public static func buildEither(second: [any ICSNode]) -> [any ICSNode] { second }
    public static func buildOptional(_ part: [any ICSNode]?) -> [any ICSNode] { part ?? [] }

    public static func buildExpression(_ node: any ICSNode) -> [any ICSNode] { [node] }
    public static func buildExpression(_ nodes: [any ICSNode]) -> [any ICSNode] { nodes }
}

