import DSL
import Foundation
import Path

/// A site's assets, declared once (W4 generates this from `assets.frame`),
/// with their paths planned up front so pages can link to them while they
/// render. The materializer adds them to the tree at exactly these paths.
public struct ArtifactAssetCatalog:
    Sendable,
    Equatable
{
    public struct Entry:
        Sendable,
        Equatable
    {
        public let key: StructuredContent.AssetKey
        public let source: ArtifactAssetSource
        public let path: StandardPath
    }

    public private(set) var entries: [Entry] = []
    private var positions: [StructuredContent.AssetKey: Int] = [:]

    public static var empty: Self {
        .init()
    }

    public init() {}

    /// Plans each asset's path with `profile` (content hashes included when
    /// the profile asks for them). A key may appear once.
    public init(
        _ assets: [(StructuredContent.AssetKey, ArtifactAssetSource)],
        profile: ArtifactPathProfile = .standard
    ) throws {
        for (key, source) in assets {
            guard positions[key] == nil else {
                throw ArtifactTreeError.duplicateKey(.asset(key))
            }

            let artifact = Artifact.asset(source)
            let path = try profile.path(
                for: .asset(key),
                artifact: artifact,
                bytes: { try artifact.bytes(ArtifactRenderProfile()) }
            )

            positions[key] = entries.count
            entries.append(.init(key: key, source: source, path: path))
        }
    }

    public func entry(
        _ key: StructuredContent.AssetKey
    ) -> Entry? {
        positions[key].map { entries[$0] }
    }

    /// The asset's root-relative URL; an unknown key is a link error.
    public func href(
        _ key: StructuredContent.AssetKey
    ) throws -> String {
        guard let entry = entry(key) else {
            throw ArtifactTreeError.unresolvedLink(.asset(key))
        }

        return entry.path.rendered(asRootPath: true)
    }
}

/// Assets only; pages resolve through the route table.
extension ArtifactAssetCatalog: StructuredContentURLResolving {
    public func url(
        page: StructuredContent.PageKey,
        anchor: StructuredContent.AnchorKey?
    ) -> String? {
        nil
    }

    public func url(
        asset: StructuredContent.AssetKey
    ) -> String? {
        try? href(asset)
    }
}
