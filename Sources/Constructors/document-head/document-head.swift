import DSL
import Foundation

/// The head every page of a site shares, declared once. The integrator turns
/// it, plus each page's `DocumentHead`, into `<title>`, meta and link tags;
/// every URL in it is derived (canonical from the route, icons and images
/// from the asset catalog).
public struct SiteHead:
    Sendable,
    Equatable
{
    public var siteName: String
    /// Between the page title and the site name (`Consult · Hondenmeesters`);
    /// nil shows the page title alone. A page titled like the site shows the
    /// site name once.
    public var titleSeparator: String?
    public var description: String?
    /// Absolute base for canonical and Open Graph URLs
    /// (`https://hondenmeesters.nl`); without it neither is emitted.
    public var canonicalBase: URL?
    /// `lang` on `<html>`.
    public var language: String?
    public var icon: StructuredContent.AssetKey?
    public var appleTouchIcon: StructuredContent.AssetKey?
    public var manifest: StructuredContent.AssetKey?
    public var themeColor: ThemeColor?
    /// The default Open Graph image.
    public var image: StructuredContent.AssetKey?
    public var openGraph: Bool

    public init(
        siteName: String,
        titleSeparator: String? = " · ",
        description: String? = nil,
        canonicalBase: URL? = nil,
        language: String? = nil,
        icon: StructuredContent.AssetKey? = nil,
        appleTouchIcon: StructuredContent.AssetKey? = nil,
        manifest: StructuredContent.AssetKey? = nil,
        themeColor: ThemeColor? = nil,
        image: StructuredContent.AssetKey? = nil,
        openGraph: Bool = true
    ) {
        self.siteName = siteName
        self.titleSeparator = titleSeparator
        self.description = description
        self.canonicalBase = canonicalBase
        self.language = language
        self.icon = icon
        self.appleTouchIcon = appleTouchIcon
        self.manifest = manifest
        self.themeColor = themeColor
        self.image = image
        self.openGraph = openGraph
    }

    /// Assets the head links to on every page; they are exported even when
    /// only used assets are.
    public var assets: [StructuredContent.AssetKey] {
        [icon, appleTouchIcon, manifest, image].compactMap { $0 }
    }
}

/// One page's head: overrides of the site defaults.
public struct DocumentHead:
    Sendable,
    Equatable
{
    /// Defaults to the page's title in the page graph.
    public var title: String?
    public var description: String?
    public var image: StructuredContent.AssetKey?
    /// Keep the page out of search indexes.
    public var noindex: Bool

    public init(
        title: String? = nil,
        description: String? = nil,
        image: StructuredContent.AssetKey? = nil,
        noindex: Bool = false
    ) {
        self.title = title
        self.description = description
        self.image = image
        self.noindex = noindex
    }

    public var assets: [StructuredContent.AssetKey] {
        [image].compactMap { $0 }
    }
}
