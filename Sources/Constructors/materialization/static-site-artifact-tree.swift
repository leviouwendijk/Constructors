import Path

public extension StaticIntegratedSiteMaterializationPlan {
    /// The integrated site as an `ArtifactTree`: every document by route and
    /// the site stylesheet by bundle, placed by `paths`. Throws when a path
    /// the materialization steps chose disagrees with the profile.
    func artifactTree(
        paths: ArtifactPathProfile,
        render: ArtifactRenderProfile,
        stylesheet bundle: ArtifactBundle
    ) throws -> ArtifactTree {
        var tree = ArtifactTree(
            profile: paths,
            render: render
        )

        for document in documents {
            let key = ArtifactKey.document(document.route)
            let planned = try tree.add(
                .document(document.document),
                as: key
            )
            try Self.check(key, planned, document.output)
        }

        let stylesheet = source.dependencies.stylesheet
        let key = ArtifactKey.stylesheet(bundle)
        let planned = try tree.add(
            .stylesheet(stylesheet.stylesheet),
            as: key
        )
        try Self.check(key, planned, stylesheet.output)

        for asset in source.dependencies.assets {
            let key = ArtifactKey.asset(asset.key)
            let planned = try tree.add(
                .asset(asset.source),
                as: key
            )
            try Self.check(key, planned, asset.path)
        }

        for file in source.dependencies.scriptFiles {
            let key = ArtifactKey.script(file.bundle)
            let planned = try tree.add(
                .script(file.source),
                as: key
            )
            try Self.check(key, planned, file.output)
        }

        return tree
    }

    private static func check(
        _ key: ArtifactKey,
        _ planned: StandardPath,
        _ materialized: StandardPath
    ) throws {
        let plannedPath = planned.rendered(asRootPath: false)
        let materializedPath = materialized.rendered(asRootPath: false)

        guard plannedPath == materializedPath else {
            throw ArtifactTreeError.pathMismatch(
                key,
                planned: plannedPath,
                materialized: materializedPath
            )
        }
    }
}
