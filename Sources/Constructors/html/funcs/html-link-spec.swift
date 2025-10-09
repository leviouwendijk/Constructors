import Foundation

public enum LinkSpec: Sendable {
    case preconnect(href: String)
    case preloadImage(
            href: String,
            imagesrcset: String? = nil,
            imagesizes: String? = nil,
            media: String? = nil,
            fetchpriority: String? = nil,
            type: String = "image/jpeg",
            as: String = "image"
        )
    case dnsPrefetch(href: String)
    case prefetchDocument(href: String)
    case modulePreload(href: String, crossorigin: String? = nil)
    case stylesheet(href: String)
    case icon(href: String, type: String = "image/x-icon")
    case appleTouchIcon(href: String, sizes: String, alt: String? = nil)
    case canonical(href: String)
    case alternate(hreflang: String, href: String)
    case manifest(href: String)

    public func attributes() -> HTMLAttribute {
        switch self {
        case .preconnect(let href):
            let a: HTMLAttribute = ["rel":"preconnect", "href": href]
            return a

        case .preloadImage(let href, let imagesrcset, let imagesizes, let media, let fetchpriority, let type, let asVal):
            var a: HTMLAttribute = ["rel":"preload", "as": asVal, "type": type, "href": href]
            if let imagesrcset   { a.merge(["imagesrcset": imagesrcset]) }
            if let imagesizes    { a.merge(["imagesizes": imagesizes]) }
            if let media         { a.merge(["media": media]) }
            if let fetchpriority { a.merge(["fetchpriority": fetchpriority]) }
            return a

        case .dnsPrefetch(let href):
            let a: HTMLAttribute = ["rel":"dns-prefetch","href":href]
            return a

        case .prefetchDocument(let href):
            let a: HTMLAttribute = ["rel":"prefetch","href": href, "as": "document"]
            return a 

        case .modulePreload(let href, let co):
            var a: HTMLAttribute = ["rel":"modulepreload","href": href]
            if let co { a.merge(["crossorigin": co]) }
            return a

        case .stylesheet(let href):
            let a: HTMLAttribute = ["rel":"stylesheet", "href": href]
            return a

        case .icon(let href, let type):
            let a: HTMLAttribute = ["rel":"icon", "href": href, "type": type]
            return a

        case .appleTouchIcon(let href, let sizes, let alt):
            var a: HTMLAttribute = ["rel":"apple-touch-icon", "href": href, "sizes": sizes]
            if let alt { a.merge(["alt": alt]) }
            return a

        case .canonical(let href):
            let a: HTMLAttribute = ["rel":"canonical", "href": href]
            return a

        case .alternate(let hreflang, let href):
            let a: HTMLAttribute = ["rel":"alternate", "hreflang": hreflang, "href": href]
            return a

        case .manifest(let href):
            let a: HTMLAttribute = ["rel":"manifest", "href": href]
            return a
        }
    }
}
