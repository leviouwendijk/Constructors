import DSL
import Foundation
import Path
import Primitives

/// Declared sites: `@Site` types, their pages, and what links them.
public enum Site {}

public extension Site {
    /// A page of a declared site, as a value: what links, hover cards and the
    /// route table refer to. `@Page` generates these; they can be written by
    /// hand too.
    struct Page:
        Sendable,
        Hashable
    {
        /// The site's host (`hondenmeesters.nl`).
        public let host: String
        /// Route segments from the site root; empty for the root page.
        public let path: [String]
        public let title: String
        /// One line for hover cards, indexes and the meta description.
        public let summary: String?
        public let visibility: Set<BuildEnvironment>

        public init(
            host: String,
            path: [String],
            title: String,
            summary: String? = nil,
            visibility: Set<BuildEnvironment> = Set(BuildEnvironment.allCases)
        ) {
            self.host = host
            self.path = path
            self.title = title
            self.summary = summary
            self.visibility = visibility
        }

        public init<Declared: Site.Declaring>(
            _ site: Declared.Type,
            path: [String],
            title: String,
            summary: String? = nil,
            visibility: Set<BuildEnvironment> = Set(BuildEnvironment.allCases)
        ) {
            self.init(
                host: Declared.host,
                path: path,
                title: title,
                summary: summary,
                visibility: visibility
            )
        }

        /// `aanbod.consult`; the root page is `index`.
        public var identifier: PageIdentifier {
            .init(rawValue: path.isEmpty ? "index" : path.joined(separator: "."))
        }

        /// `/aanbod/consult/`.
        public var href: String {
            path.isEmpty ? "/" : "/" + path.joined(separator: "/") + "/"
        }

        /// The key StructuredContent links carry: `<host>/<path>`, so a link
        /// resolves within its own site or across to another.
        public var pageKey: StructuredContent.PageKey {
            .init(rawValue: ([host] + path).joined(separator: "/"))
        }
    }

    struct PageIdentifier:
        StringIdentifier
    {
        public let rawValue: String

        public init(
            rawValue: String
        ) {
            self.rawValue = rawValue
        }
    }

}

public extension Site {
    /// A site: its host, where it is served, and its pages. `@Site` generates
    /// the conformance from the type's `@Page` members.
    protocol Declaring:
        Sendable
    {
        static var host: String { get }
        /// Absolute base for canonical URLs and links from other sites;
        /// defaults to `https://<host>`.
        static var canonicalBase: URL { get }
        /// Every page, in declaration order. Parents come from paths: a page's
        /// parent is the page whose path is its path minus the last segment.
        static var pages: [Site.Page] { get }
    }
}

public extension Site.Declaring {
    static var canonicalBase: URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = host
        return components.url ?? URL(fileURLWithPath: "/")
    }
}
