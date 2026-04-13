public typealias SiteDeclaration<Site: SiteDeclaring> = Declarations<
    Site.DocumentIdentifier,
    Site.StyleIdentifier,
    Site.SnippetIdentifier
>
