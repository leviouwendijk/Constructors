public enum CSSBlock: Sendable, Equatable {
    case rule(CSSRule)
    case media(CSSMediaBlock)
}
