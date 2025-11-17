import Foundation

@resultBuilder
public enum CSSDeclBuilder {
    public static func buildBlock(_ parts: CSSDeclaration...) -> [CSSDeclaration] {
        parts
    }
    public static func buildExpression(_ decl: CSSDeclaration) -> [CSSDeclaration] { [decl] }
    public static func buildExpression(_ decls: [CSSDeclaration]) -> [CSSDeclaration] { decls }
}
