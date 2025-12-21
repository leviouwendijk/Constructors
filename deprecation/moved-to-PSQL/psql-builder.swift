import Foundation

extension PSQL {
    @resultBuilder
    public enum BoolExprBuilder {
        public static func buildBlock(_ parts: [any SQLRenderable]...) -> [any SQLRenderable] { parts.flatMap{$0} }
        public static func buildExpression(_ e: any SQLRenderable) -> [any SQLRenderable] { [e] }
        public static func buildOptional(_ e: [any SQLRenderable]?) -> [any SQLRenderable] { e ?? [] }
        public static func buildEither(first: [any SQLRenderable]) -> [any SQLRenderable] { first }
        public static func buildEither(second: [any SQLRenderable]) -> [any SQLRenderable] { second }
    }

    @resultBuilder
    public enum ListBuilder {
        public static func buildBlock(_ parts: [any SQLRenderable]...) -> [any SQLRenderable] { parts.flatMap{$0} }
        public static func buildExpression(_ e: any SQLRenderable) -> [any SQLRenderable] { [e] }
        public static func buildOptional(_ e: [any SQLRenderable]?) -> [any SQLRenderable] { e ?? [] }
        public static func buildEither(first: [any SQLRenderable]) -> [any SQLRenderable] { first }
        public static func buildEither(second: [any SQLRenderable]) -> [any SQLRenderable] { second }
    }
}
