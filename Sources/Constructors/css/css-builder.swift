@resultBuilder
public enum CSSBuilder {
    public static func buildBlock(_ parts: [CSSBlock]...) -> [CSSBlock] {
        parts.flatMap { $0 }
    }

    public static func buildArray(_ parts: [[CSSBlock]]) -> [CSSBlock] {
        parts.flatMap { $0 }
    }

    public static func buildEither(first: [CSSBlock]) -> [CSSBlock] {
        first
    }

    public static func buildEither(second: [CSSBlock]) -> [CSSBlock] {
        second
    }

    public static func buildOptional(_ part: [CSSBlock]?) -> [CSSBlock] {
        part ?? []
    }

    public static func buildExpression(_ rule: CSSRule) -> [CSSBlock] {
        [.rule(rule)]
    }

    public static func buildExpression(_ media: CSSMedia) -> [CSSBlock] {
        [.media(media)]
    }

    public static func buildExpression(_ blocks: [CSSBlock]) -> [CSSBlock] {
        blocks
    }

    public static func buildExpression(_ keyframes: CSSKeyframes) -> [CSSBlock] {
        [.keyframes(keyframes)]
    }
}
