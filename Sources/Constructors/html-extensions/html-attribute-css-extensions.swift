import HTML
import CSS

extension HTMLAttribute {
    public static func style(_ css: String) -> HTMLAttribute {
        ["style": css]
    }

    public static func style(_ declarations: [CSSDeclaration]) -> HTMLAttribute {
        ["style": declarations.renderInline()]
    }

    public static func style(_ declarations: CSSDeclaration...) -> HTMLAttribute {
        .style(declarations)
    }

    public static func style(@CSSDeclBuilder _ c: () -> [CSSDeclaration]) -> HTMLAttribute {
        .style(c())
    }
}
