import JS

public struct StaticDependencyPackager:
    Sendable
{
    public let policy:
        StaticDependencyPackagingPolicy

    public init(
        policy:
            StaticDependencyPackagingPolicy =
                .init()
    ) {
        self.policy =
            policy
    }

    public func pack(
        _ dependencies:
            RenderDependencies
    ) throws -> StaticDependencyPackaging {
        let stylesheet =
            StaticStylesheetArtifactPlan(
                output:
                    try policy
                        .styles
                        .output(),
                selection:
                    policy
                        .styles
                        .selection,
                sourceContributionIdentifiers:
                    dependencies
                        .styles
                        .identifiers,
                stylesheet:
                    dependencies
                        .styles
                        .collected(
                            policy
                                .styles
                                .selection
                        )
            )

        var scripts =
            dependencies
                .scripts
                .contributions
                .map { contribution in
                    StaticJavaScriptDependency(
                        identifier:
                            contribution
                                .identifier,
                        scope:
                            contribution
                                .scope,
                        script:
                            contribution
                                .script
                    )
                }

        var files: [StaticScriptArtifactPlan] = []

        if policy.scripts.delivery != .preserve {
            var order: [ArtifactBundle] = []
            var members: [ArtifactBundle: (loading: JSScriptLoading, identifiers: [JSContributionIdentifier], sources: [JSSource])] = [:]

            for index in scripts.indices {
                guard let source = scripts[index].script.source else {
                    continue
                }

                let loading = scripts[index].script.loading
                let bundle = Self.bundle(
                    for: scripts[index].identifier,
                    loading: loading,
                    delivery: policy.scripts.delivery
                )

                scripts[index].file = bundle

                if members[bundle] == nil {
                    order.append(bundle)
                    members[bundle] = (loading, [], [])
                }

                members[bundle]?.identifiers.append(scripts[index].identifier)
                members[bundle]?.sources.append(source)
            }

            files = try order.map { bundle in
                let member = members[bundle]!
                return StaticScriptArtifactPlan(
                    bundle: bundle,
                    output: try policy.scripts.paths.scriptPath(bundle),
                    loading: member.loading,
                    members: member.identifiers,
                    source: JSSource(
                        member.sources
                            .map { $0.render() }
                            .joined(separator: "\n;\n")
                    )
                )
            }
        }

        var packaging =
            StaticDependencyPackaging(
                stylesheet:
                    stylesheet,
                scripts:
                    scripts
            )
        packaging.scriptFiles = files
        return packaging
    }

    /// `files`: one per identifier. `bundled`: `site` for classic scripts,
    /// with `-defer` / `-async` for those loadings; modules one per
    /// identifier.
    private static func bundle(
        for identifier: JSContributionIdentifier,
        loading: JSScriptLoading,
        delivery: StaticJavaScriptPackagingPolicy.Delivery
    ) -> ArtifactBundle {
        if delivery == .files || loading.kind == .module {
            return .init(rawValue: identifier.rawValue)
        }

        var name = "site"
        if loading.defer_loading { name += "-defer" }
        if loading.async_loading { name += "-async" }
        return .init(rawValue: name)
    }

    public func pack<
        Page:
            PageGraphNode
    >(
        _ site:
            StaticSiteDocumentMaterialization<Page>
    ) throws -> StaticSiteMaterializationPlan<Page> {
        try StaticSiteMaterializationPlan(
            site:
                site,
            dependencies:
                pack(
                    site
                        .dependencies
                )
        )
    }
}
