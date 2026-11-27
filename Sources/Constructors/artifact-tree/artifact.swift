import CSS
import DSL
import Foundation
import HTML
import JS
import Path
import Readers

/// What an artifact is known by: the thing documents link to. Its path is
/// planned by the tree, never written by hand.
public enum ArtifactKey:
    Sendable,
    Hashable,
    CustomStringConvertible
{
    case document(SiteRoute)
    case stylesheet(ArtifactBundle)
    case script(ArtifactBundle)
    case asset(StructuredContent.AssetKey)
    /// A file named by its own path: `robots.txt`, `sitemap.xml`, `llms.txt`.
    case text(StandardPath)

    public var description: String {
        switch self {
        case .document(let route):
            return "document \(route)"
        case .stylesheet(let bundle):
            return "stylesheet \(bundle.rawValue)"
        case .script(let bundle):
            return "script \(bundle.rawValue)"
        case .asset(let asset):
            return "asset \(asset.rawValue)"
        case .text(let path):
            return "text \(path.rendered(asRootPath: false))"
        }
    }
}

/// A named group of styles or scripts delivered as one file.
public struct ArtifactBundle:
    RawRepresentable,
    Sendable,
    Hashable
{
    public let rawValue: String

    public init(
        rawValue: String
    ) {
        self.rawValue = rawValue
    }

    public static var site: Self {
        .init(rawValue: "site")
    }
}

/// Where an asset's bytes come from.
public enum ArtifactAssetSource:
    Sendable,
    Hashable
{
    /// Bytes already in memory, with the file extension they are served as.
    case bytes(Data, extension: String)
    /// A file on disk, read when the bytes are first needed.
    case file(URL)

    public var fileExtension: String {
        switch self {
        case .bytes(_, let ext):
            return ext
        case .file(let url):
            return url.pathExtension
        }
    }
}

/// A leaf of the tree: a structured value, turned into bytes only at the
/// sink.
public enum Artifact:
    Sendable
{
    case document(HTMLDocument)
    case stylesheet(CSSStyleSheet)
    case script(JSSource)
    case asset(ArtifactAssetSource)
    case text(String)

    public var kind: ArtifactKind {
        switch self {
        case .document: .document
        case .stylesheet: .stylesheet
        case .script: .script
        case .asset: .asset
        case .text: .text
        }
    }

    public func bytes(
        _ profile: ArtifactRenderProfile
    ) throws -> Data {
        switch self {
        case .document(let document):
            return Data(document.render(options: profile.html).utf8)
        case .stylesheet(let stylesheet):
            return Data(stylesheet.render(options: profile.stylesheet).utf8)
        case .script(let source):
            return Data(source.render().utf8)
        case .asset(.bytes(let data, _)):
            return data
        case .asset(.file(let url)):
            return try DataFileReader(url).read().data
        case .text(let text):
            return Data(text.utf8)
        }
    }
}

public enum ArtifactKind:
    String,
    Sendable,
    Hashable,
    CaseIterable
{
    case document
    case stylesheet
    case script
    case asset
    case text
}

/// How structured leaves become text.
public struct ArtifactRenderProfile:
    Sendable
{
    public var html: HTMLRenderOptions
    public var stylesheet: CSSRenderOptions

    public init(
        html: HTMLRenderOptions = .Defaults.pretty(),
        stylesheet: CSSRenderOptions = CSSRenderOptions(ensureTrailingNewline: true)
    ) {
        self.html = html
        self.stylesheet = stylesheet
    }
}
