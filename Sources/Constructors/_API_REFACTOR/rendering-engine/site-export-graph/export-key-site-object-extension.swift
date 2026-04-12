public extension SiteObject {
    static func export_key(
        documentKey key: String
    ) -> ExportKey {
        .document(key)
    }

    static func export_key(
        stylesheetKey key: String
    ) -> ExportKey {
        .stylesheet(key)
    }

    static func export_key(
        snippetKey key: String
    ) -> ExportKey {
        .snippet(key)
    }

    static func export_key(
        page: Page
    ) -> ExportKey {
        .document(page.rawValue)
    }

    static func export_key(
        stylesheet: Stylesheet
    ) -> ExportKey {
        .stylesheet(stylesheet.rawValue)
    }

    static func export_key(
        snippet: Snippet
    ) -> ExportKey {
        .snippet(snippet.rawValue)
    }

    static func export_key(
        document: SiteDocumentDefinition
    ) -> ExportKey {
        .document(document.id)
    }
}

public extension SiteDeclaring {
    static func export_key(
        document: DocumentIdentifier
    ) -> ExportKey {
        .document(document.rawValue)
    }

    static func export_key(
        style: StyleIdentifier
    ) -> ExportKey {
        .stylesheet(style.rawValue)
    }

    static func export_key(
        snippet: SnippetIdentifier
    ) -> ExportKey {
        .snippet(snippet.rawValue)
    }

    static func export_key(
        document: DocumentDeclaration<DocumentIdentifier>
    ) -> ExportKey {
        .document(document.id.rawValue)
    }

    static func export_key(
        style: StyleDeclaration<StyleIdentifier>
    ) -> ExportKey {
        .stylesheet(style.id.rawValue)
    }

    static func export_key(
        snippet: SnippetDeclaration<SnippetIdentifier>
    ) -> ExportKey {
        .snippet(snippet.id.rawValue)
    }
}
