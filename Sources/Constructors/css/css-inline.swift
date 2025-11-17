extension Array where Element == CSSDeclaration {
    public func renderInline() -> String {
        return CSS.inline(self)
    }
}
