public enum CSSBlock: Sendable, Equatable {
    case rule(CSSRule)
    case media(CSSMedia)
    case keyframes(CSSKeyframes)
}
