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
    ) -> StaticDependencyPackaging {
        let stylesheet =
            StaticStylesheetArtifactPlan(
                output:
                    policy
                        .styles
                        .output,
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

        let scripts:
            [StaticJavaScriptDependency]

        switch policy.scripts {
        case .preserve:
            scripts =
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
        }

        return
            StaticDependencyPackaging(
                stylesheet:
                    stylesheet,
                scripts:
                    scripts
            )
    }

    public func pack<
        Page:
            PageGraphNode
    >(
        _ site:
            StaticSiteDocumentMaterialization<Page>
    ) -> StaticSiteMaterializationPlan<Page> {
        StaticSiteMaterializationPlan(
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
