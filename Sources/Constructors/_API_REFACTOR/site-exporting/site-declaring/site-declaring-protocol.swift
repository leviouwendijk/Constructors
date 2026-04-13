public protocol SiteDeclaring: SiteObject {
    associatedtype DocumentIdentifier: DeclarationIdentifier = _EmptyDeclarationIdentifiers
    associatedtype StyleIdentifier: DeclarationIdentifier = _EmptyDeclarationIdentifiers
    associatedtype SnippetIdentifier: DeclarationIdentifier = _EmptyDeclarationIdentifiers

    static func declarations() throws -> Declarations<
        DocumentIdentifier,
        StyleIdentifier,
        SnippetIdentifier
    >

    static func declaration_exports() throws -> [BundleExportDefinition]
}

public extension SiteDeclaring {
    static func declarations() throws -> Declarations<
        DocumentIdentifier,
        StyleIdentifier,
        SnippetIdentifier
    > {
        Declarations()
    }

    static func declaration_exports() throws -> [BundleExportDefinition] {
        let siteDeclarations = try declarations()

        let documents = siteDeclarations.documents
            .keys
            .sorted { $0.rawValue < $1.rawValue }
            .compactMap { key in
                siteDeclarations.documents[key]?.export
            }

        let styles = siteDeclarations.styles
            .keys
            .sorted { $0.rawValue < $1.rawValue }
            .compactMap { key in
                siteDeclarations.styles[key]?.export
            }

        let snippets = siteDeclarations.snippets
            .keys
            .sorted { $0.rawValue < $1.rawValue }
            .compactMap { key in
                siteDeclarations.snippets[key]?.export
            }

        return documents + styles + snippets
    }
}
