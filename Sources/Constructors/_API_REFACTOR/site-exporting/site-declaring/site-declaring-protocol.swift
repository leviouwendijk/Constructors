import Primitives

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

    static func declaration_navigation(
        env: BuildEnvironment,
        sort_order: NavigationSortOrder
    ) throws -> NavigationStructure
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

        let documents = DocumentIdentifier.allCases
            .compactMap { key in
                siteDeclarations.documents[key]?.export
            }

        let styles = StyleIdentifier.allCases
            .compactMap { key in
                siteDeclarations.styles[key]?.export
            }

        let snippets = SnippetIdentifier.allCases
            .compactMap { key in
                siteDeclarations.snippets[key]?.export
            }

        return documents + styles + snippets
    }

    // static func declaration_exports() throws -> [BundleExportDefinition] {
    //     let siteDeclarations = try declarations()

    //     let documents = siteDeclarations.documents
    //         .keys
    //         .sorted { $0.rawValue < $1.rawValue }
    //         .compactMap { key in
    //             siteDeclarations.documents[key]?.export
    //         }

    //     let styles = siteDeclarations.styles
    //         .keys
    //         .sorted { $0.rawValue < $1.rawValue }
    //         .compactMap { key in
    //             siteDeclarations.styles[key]?.export
    //         }

    //     let snippets = siteDeclarations.snippets
    //         .keys
    //         .sorted { $0.rawValue < $1.rawValue }
    //         .compactMap { key in
    //             siteDeclarations.snippets[key]?.export
    //         }

    //     return documents + styles + snippets
    // }

    static func declaration_navigation(
        env: BuildEnvironment,
        sort_order: NavigationSortOrder = .insertion
    ) throws -> NavigationStructure {
        let siteDeclarations = try declarations()

        let documents = DocumentIdentifier.allCases
            .compactMap { key in
                siteDeclarations.documents[key]
            }

        return NavigationStructure.build(
            from: documents,
            env: env,
            sort_order: sort_order
        )
    }
}
