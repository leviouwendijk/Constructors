import DSL
import Foundation
import Path

public enum ArtifactTreeError:
    Error,
    Sendable,
    Equatable
{
    case duplicateKey(ArtifactKey)
    /// Two artifacts planned onto one path.
    case duplicatePath(String, ArtifactKey, ArtifactKey)
    case kindMismatch(key: ArtifactKey, kind: ArtifactKind)
    case invalidAssetKey(String)
    /// A document links to an artifact the tree doesn't have.
    case unresolvedLink(ArtifactKey)
    /// A materialization step placed an artifact somewhere other than the
    /// tree's profile does (two profiles in one build).
    case pathMismatch(ArtifactKey, planned: String, materialized: String)
}

/// The low-level IR: every artifact of a site by key, each with its planned
/// path. Documents link to keys; the tree turns keys into paths and hrefs,
/// so a path and the links to it can't disagree. Bytes are made at the sink
/// and memoized per leaf.
public struct ArtifactTree:
    Sendable
{
    public struct Entry:
        Sendable
    {
        public let key: ArtifactKey
        public let path: StandardPath
        public let artifact: Artifact
    }

    public let profile: ArtifactPathProfile
    public let render: ArtifactRenderProfile

    /// Entries in insertion order.
    public private(set) var entries: [Entry] = []
    private var positions: [ArtifactKey: Int] = [:]
    private var owners: [String: ArtifactKey] = [:]
    private var cache = ArtifactBytesCache()

    public init(
        profile: ArtifactPathProfile = .standard,
        render: ArtifactRenderProfile = .init()
    ) {
        self.profile = profile
        self.render = render
    }

    /// Adds `artifact` under `key` at the profile's path for it.
    @discardableResult
    public mutating func add(
        _ artifact: Artifact,
        as key: ArtifactKey
    ) throws -> StandardPath {
        guard positions[key] == nil else {
            throw ArtifactTreeError.duplicateKey(key)
        }

        try Self.check(key, artifact)

        let render = render
        let path = try profile.path(
            for: key,
            artifact: artifact,
            bytes: { try artifact.bytes(render) }
        )
        let rendered = path.rendered(asRootPath: false)

        if let owner = owners[rendered] {
            throw ArtifactTreeError.duplicatePath(rendered, owner, key)
        }

        owners[rendered] = key
        positions[key] = entries.count
        entries.append(.init(key: key, path: path, artifact: artifact))
        cache = ArtifactBytesCache()
        return path
    }

    public func entry(
        _ key: ArtifactKey
    ) -> Entry? {
        positions[key].map { entries[$0] }
    }

    public func path(
        for key: ArtifactKey
    ) -> StandardPath? {
        entry(key)?.path
    }

    /// The root-relative URL of `key` (`/assets/css/site.css`, `/guide/`).
    /// A document's `index.html` is left off, as served.
    public func href(
        for key: ArtifactKey
    ) throws -> String {
        guard let path = path(for: key) else {
            throw ArtifactTreeError.unresolvedLink(key)
        }

        let rendered = path.rendered(asRootPath: true)

        if case .document = key,
           rendered.hasSuffix("/index.html")
        {
            return String(rendered.dropLast("index.html".count))
        }

        return rendered
    }

    /// The artifact's bytes, made once.
    public func bytes(
        for key: ArtifactKey
    ) throws -> Data {
        guard let entry = entry(key) else {
            throw ArtifactTreeError.unresolvedLink(key)
        }

        return try cache.value(for: key) {
            try entry.artifact.bytes(render)
        }
    }

    /// The planned files as a `PathTree`, for rendering a plan or
    /// `PathTree.difference` against an existing export.
    public var pathTree: PathTree {
        var tree = PathTree(root: StandardPath(), children: [])

        for entry in entries {
            try? tree.appendPath(entry.path)
        }

        return tree
    }

    private static func check(
        _ key: ArtifactKey,
        _ artifact: Artifact
    ) throws {
        let expected: ArtifactKind
        switch key {
        case .document: expected = .document
        case .stylesheet: expected = .stylesheet
        case .script: expected = .script
        case .asset: expected = .asset
        case .text: expected = .text
        }

        guard artifact.kind == expected else {
            throw ArtifactTreeError.kindMismatch(key: key, kind: artifact.kind)
        }
    }
}

/// Page and asset URLs for StructuredContent (W1.2), from the same plan.
/// Pages are keyed by their route's path (`guide/setup`).
extension ArtifactTree: StructuredContentURLResolving {
    public func url(
        page: StructuredContent.PageKey,
        anchor: StructuredContent.AnchorKey?
    ) -> String? {
        let path = page.rawValue.hasPrefix("/") ? page.rawValue : "/" + page.rawValue

        guard let route = try? SiteRoute(parsingPath: path),
              let href = try? href(for: .document(route))
        else {
            return nil
        }

        return anchor.map { href + "#" + $0.rawValue } ?? href
    }

    public func url(
        asset: StructuredContent.AssetKey
    ) -> String? {
        try? href(for: .asset(asset))
    }
}

private final class ArtifactBytesCache:
    @unchecked Sendable
{
    private let lock = NSLock()
    private var values: [ArtifactKey: Data] = [:]

    func value(
        for key: ArtifactKey,
        make: () throws -> Data
    ) throws -> Data {
        lock.lock()
        if let value = values[key] {
            lock.unlock()
            return value
        }
        lock.unlock()

        let value = try make()

        lock.lock()
        values[key] = value
        lock.unlock()
        return value
    }
}
