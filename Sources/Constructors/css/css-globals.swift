import Foundation

@inlinable
public func decl(
    _ property: String,
    _ value: String
) -> CSSDeclaration {
    CSS.decl(property, value)
}

@inlinable
public func rule(
    _ selector: String,
    _ declarations: [CSSDeclaration]
) -> CSSRule {
    CSS.rule(selector, declarations)
}

@inlinable
public func rule(
    _ selector: String,
    _ declarations: CSSDeclaration...
) -> CSSRule {
    CSS.rule(selector, declarations)
}

@inlinable
public func rule(
    _ selector: CSSSelector,
    _ declarations: [CSSDeclaration]
) -> CSSRule {
    CSS.rule(selector, declarations)
}

@inlinable
public func rule(
    _ selector: CSSSelector,
    _ declarations: CSSDeclaration...
) -> CSSRule {
    CSS.rule(selector, declarations)
}

@inlinable
public func media(
    _ query: String,
    _ rules: [CSSRule]
) -> CSSMedia {
    CSS.media(query, rules)
}

@inlinable
public func media(
    _ query: String,
    _ rules: CSSRule...
) -> CSSMedia {
    CSS.media(query, rules)
}

@inlinable
public func keyframes(
    _ name: String,
    @CSS.CSSKeyframeStepBuilder _ steps: () -> [CSSKeyframeStep]
) -> CSSKeyframes {
    CSS.keyframes(name, steps)
}

@inlinable
public func step(
    _ selector: String,
    _ declarations: [CSSDeclaration]
) -> CSSKeyframeStep {
    CSS.step(selector, declarations)
}

@inlinable
public func step(
    _ selector: String,
    @CSSDeclBuilder _ declarations: () -> [CSSDeclaration]
) -> CSSKeyframeStep {
    CSS.step(selector, declarations)
}

@inlinable
public func from(
    @CSSDeclBuilder _ declarations: () -> [CSSDeclaration]
) -> CSSKeyframeStep {
    CSS.from(declarations)
}

@inlinable
public func to(
    @CSSDeclBuilder _ declarations: () -> [CSSDeclaration]
) -> CSSKeyframeStep {
    CSS.to(declarations)
}

@inlinable
public func pct(
    _ value: Int,
    @CSSDeclBuilder _ declarations: () -> [CSSDeclaration]
) -> CSSKeyframeStep {
    CSS.pct(value, declarations)
}

@inlinable
public func cssInline(
    _ declarations: [CSSDeclaration]
) -> String {
    CSS.inline(declarations)
}

@inlinable
public func cssInline(
    _ declarations: CSSDeclaration...
) -> String {
    CSS.inline(declarations)
}


@inlinable
public func stylesheet(
    rules: [CSSRule],
    media: [CSSMedia] = [],
    keyframes: [CSSKeyframes] = []
) -> CSSStyleSheet {
    CSSStyleSheet(
        rules: rules,
        media: media,
        keyframes: keyframes
    )
}
