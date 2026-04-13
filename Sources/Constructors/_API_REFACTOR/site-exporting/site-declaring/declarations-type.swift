public struct Declarations<
    DocumentIdentifier: DeclarationIdentifier,
    StyleIdentifier: DeclarationIdentifier,
    SnippetIdentifier: DeclarationIdentifier
>: Sendable {
    public let documents: [DocumentIdentifier: DocumentDeclaration<DocumentIdentifier>]
    public let styles: [StyleIdentifier: StyleDeclaration<StyleIdentifier>]
    public let snippets: [SnippetIdentifier: SnippetDeclaration<SnippetIdentifier>]

    public init(
        documents: [DocumentIdentifier: DocumentDeclaration<DocumentIdentifier>] = [:],
        styles: [StyleIdentifier: StyleDeclaration<StyleIdentifier>] = [:],
        snippets: [SnippetIdentifier: SnippetDeclaration<SnippetIdentifier>] = [:]
    ) {
        self.documents = documents
        self.styles = styles
        self.snippets = snippets
    }
}
