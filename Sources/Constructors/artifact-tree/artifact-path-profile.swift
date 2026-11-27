import FileTypes
import Foundation
import Path

/// Path templates per artifact kind. Every planned path comes from here.
public struct ArtifactPathProfile:
    Sendable
{
    /// Captured route segments.
    public static let route = PathField<[String]>("route")
    /// A bundle's name.
    public static let bundle = PathField<String>("bundle")

    /// `{route}/index.html`.
    public var document: PathLayout
    /// `assets/css/{bundle}.css`.
    public var stylesheet: PathLayout
    /// `assets/js/{bundle}.js`.
    public var script: PathLayout
    /// The directory assets go under; an asset key's own segments
    /// (`images/wordmark`) follow it.
    public var assetDirectory: StandardPath
    /// Put a short content hash in asset file names
    /// (`wordmark.3f9a1c2e.svg`), so a changed file gets a new URL.
    public var hashesAssetNames: Bool

    public init(
        document: PathLayout = .init(.remainder(route), .literal("index.html")),
        stylesheet: PathLayout = .init(.literal("assets"), .literal("css"), .file(stem: bundle, extension: "css")),
        script: PathLayout = .init(.literal("assets"), .literal("js"), .file(stem: bundle, extension: "js")),
        assetDirectory: StandardPath = StandardPath("assets"),
        hashesAssetNames: Bool = false
    ) {
        self.document = document
        self.stylesheet = stylesheet
        self.script = script
        self.assetDirectory = assetDirectory
        self.hashesAssetNames = hashesAssetNames
    }

    public static var standard: Self {
        .init()
    }

    /// The planned path for `key`; `bytes` is only needed for hashed asset
    /// names.
    public func path(
        for key: ArtifactKey,
        artifact: Artifact,
        bytes: () throws -> Data
    ) throws -> StandardPath {
        var values = PathLayoutValues()

        switch key {
        case .document(let route):
            values.set(route.segments.map(\.rawValue), for: Self.route)
            return Self.typed(try document.render(values), .text(.html))

        case .stylesheet(let bundle):
            values.set(bundle.rawValue, for: Self.bundle)
            return Self.typed(try stylesheet.render(values), .text(.css))

        case .script(let bundle):
            values.set(bundle.rawValue, for: Self.bundle)
            return Self.typed(try script.render(values), .code(.js))

        case .asset(let asset):
            guard case .asset(let source) = artifact else {
                throw ArtifactTreeError.kindMismatch(key: key, kind: artifact.kind)
            }

            var segments = asset.rawValue
                .split(separator: "/")
                .map(String.init)

            guard let stem = segments.popLast(), !stem.isEmpty else {
                throw ArtifactTreeError.invalidAssetKey(asset.rawValue)
            }

            let ext = source.fileExtension
            let hash = hashesAssetNames ? "." + Self.shortHash(try bytes()) : ""
            let name = stem + hash + (ext.isEmpty ? "" : "." + ext)

            return Self.typed(
                StandardPath(
                    segments: assetDirectory.segments
                        + segments.map { PathSegment($0) }
                        + [PathSegment(name, .file)]
                ),
                nil
            )

        case .text(let path):
            return path
        }
    }

    /// `{route}/index.html` for a route.
    public func documentPath(
        _ route: SiteRoute
    ) throws -> StandardPath {
        try path(for: .document(route), artifact: .text(""), bytes: { Data() })
    }

    /// `assets/css/{bundle}.css` for a bundle.
    public func stylesheetPath(
        _ bundle: ArtifactBundle
    ) throws -> StandardPath {
        try path(for: .stylesheet(bundle), artifact: .text(""), bytes: { Data() })
    }

    /// `assets/js/{bundle}.js` for a bundle.
    public func scriptPath(
        _ bundle: ArtifactBundle
    ) throws -> StandardPath {
        try path(for: .script(bundle), artifact: .text(""), bytes: { Data() })
    }

    /// Paths in the usual `StandardPath` form: the last segment's
    /// extension moves into `filetype` (`index` + `.html`), so planned paths
    /// compare equal to hand-built ones. An extension FileTypes doesn't know
    /// stays in the name.
    static func typed(
        _ path: StandardPath,
        _ preferred: AnyFileType?
    ) -> StandardPath {
        guard path.filetype == nil,
              let last = path.segments.last,
              let dot = last.value.lastIndex(of: "."),
              dot != last.value.startIndex
        else {
            return path
        }

        let name = String(last.value[last.value.startIndex..<dot])
        let ext = String(last.value[last.value.index(after: dot)...])
        let filetype = preferred.flatMap { $0.component == "." + ext ? $0 : nil }
            ?? (try? AnyFileType(filename: last.value))

        guard let filetype else {
            return path
        }

        return StandardPath(
            segments: path.segments.dropLast() + [PathSegment(name)],
            filetype: filetype
        )
    }

    /// 8 hex digits of FNV-1a over the bytes: a cache key, not a checksum.
    static func shortHash(
        _ data: Data
    ) -> String {
        var hash: UInt32 = 2_166_136_261

        for byte in data {
            hash ^= UInt32(byte)
            hash &*= 16_777_619
        }

        let digits = String(hash, radix: 16)
        return String(repeating: "0", count: 8 - digits.count) + digits
    }
}
