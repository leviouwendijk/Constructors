import DSL
import Foundation

/// Every declared site, by host: what lets a page link to a neighbour
/// site's page by its typed handle. Within a site a link is a root-relative
/// href; across sites, an absolute URL on the target's canonical base.
public extension Site {
    struct Directory:
        Sendable
    {
        public struct Entry:
            Sendable
        {
            public let host: String
            public let canonicalBase: URL
            public let pages: [Site.Page]
        }

        public private(set) var entries: [String: Entry] = [:]

        public init(
            _ sites: [any Site.Declaring.Type]
        ) {
            for site in sites {
                entries[site.host] = .init(
                    host: site.host,
                    canonicalBase: site.canonicalBase,
                    pages: site.pages
                )
            }
        }

        /// The declared page a handle or key names, for hover cards and checks.
        public func page(
            _ key: StructuredContent.PageKey
        ) -> Site.Page? {
            let parts = key.rawValue.split(separator: "/").map(String.init)

            guard let host = parts.first,
                  let entry = entries[host]
            else {
                return nil
            }

            let path = Array(parts.dropFirst())
            return entry.pages.first { $0.path == path }
        }

        /// The URL of `page` as linked from a page of `host`. A page that isn't
        /// declared is an error, so a dropped page fails the build.
        public func href(
            for page: Site.Page,
            from host: String
        ) throws -> String {
            guard let entry = entries[page.host] else {
                throw Site.DeclarationError.unknownSite(page.host)
            }

            guard entry.pages.contains(page) else {
                throw Site.DeclarationError.unknownPage(page.pageKey.rawValue)
            }

            if page.host == host {
                return page.href
            }

            let base = entry.canonicalBase.absoluteString
            return (base.hasSuffix("/") ? String(base.dropLast()) : base) + page.href
        }

        /// A StructuredContent resolver for pages of `host`: page keys resolve
        /// through the directory, assets through `assets`.
        public func resolver(
            from host: String,
            assets: ArtifactAssetCatalog = .empty
        ) -> some StructuredContentURLResolving {
            DirectoryResolver(directory: self, host: host, assets: assets)
        }
    }
}

private struct DirectoryResolver:
    StructuredContentURLResolving
{
    let directory: Site.Directory
    let host: String
    let assets: ArtifactAssetCatalog

    func url(
        page: StructuredContent.PageKey,
        anchor: StructuredContent.AnchorKey?
    ) -> String? {
        guard let declared = directory.page(page),
              let href = try? directory.href(for: declared, from: host)
        else {
            return nil
        }

        return anchor.map { href + "#" + $0.rawValue } ?? href
    }

    func url(
        asset: StructuredContent.AssetKey
    ) -> String? {
        assets.url(asset: asset)
    }
}

public extension InlineText.StringInterpolation {
    /// A typed link to a declared page, in this site or another:
    /// `\(link: "consult", to: Sites.Hondenmeesters.Aanbod.consult)`.
    mutating func appendInterpolation(
        link text: InlineText,
        to page: Site.Page,
        anchor: StructuredContent.AnchorKey? = nil
    ) {
        appendInterpolation(
            .link(
                target: .page(page.pageKey, anchor: anchor),
                content: text.inlines
            )
        )
    }
}
