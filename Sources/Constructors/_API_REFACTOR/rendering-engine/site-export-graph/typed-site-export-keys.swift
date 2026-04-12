import Primitives

public protocol TypedSiteExportKey: Sendable, Hashable {
    var export_key: ExportKey { get }
    var site: any SiteResolvable { get }
}

public struct SiteDocumentKey<Site: SiteDeclaring>: TypedSiteExportKey {
    public let document: Site.DocumentIdentifier

    public init(
        _ document: Site.DocumentIdentifier
    ) {
        self.document = document
    }

    public var export_key: ExportKey {
        Site.export_key(document: document)
    }

    public var site: any SiteResolvable {
        Site.site
    }
}

public struct SiteStyleKey<Site: SiteDeclaring>: TypedSiteExportKey {
    public let style: Site.StyleIdentifier

    public init(
        _ style: Site.StyleIdentifier
    ) {
        self.style = style
    }

    public var export_key: ExportKey {
        Site.export_key(style: style)
    }

    public var site: any SiteResolvable {
        Site.site
    }
}

public struct SiteSnippetKey<Site: SiteDeclaring>: TypedSiteExportKey {
    public let snippet: Site.SnippetIdentifier

    public init(
        _ snippet: Site.SnippetIdentifier
    ) {
        self.snippet = snippet
    }

    public var export_key: ExportKey {
        Site.export_key(snippet: snippet)
    }

    public var site: any SiteResolvable {
        Site.site
    }
}

public extension SiteDeclaring {
    static func document_key(
        _ document: DocumentIdentifier
    ) -> SiteDocumentKey<Self> {
        SiteDocumentKey(document)
    }

    @available(
        *,
        deprecated,
        renamed: "document_key(_:)"
    )
    static func page_key(
        _ document: DocumentIdentifier
    ) -> SiteDocumentKey<Self> {
        document_key(document)
    }

    static func style_key(
        _ style: StyleIdentifier
    ) -> SiteStyleKey<Self> {
        SiteStyleKey(style)
    }

    @available(
        *,
        deprecated,
        renamed: "style_key(_:)"
    )
    static func stylesheet_key(
        _ style: StyleIdentifier
    ) -> SiteStyleKey<Self> {
        style_key(style)
    }

    static func snippet_key(
        _ snippet: SnippetIdentifier
    ) -> SiteSnippetKey<Self> {
        SiteSnippetKey(snippet)
    }
}
