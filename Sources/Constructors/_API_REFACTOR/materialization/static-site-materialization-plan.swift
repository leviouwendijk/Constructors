public struct StaticSiteMaterializationPlan<
    Page:
        PageGraphNode
>:
    Sendable
{
    public let site:
        StaticSiteDocumentMaterialization<Page>

    public let dependencies:
        StaticDependencyPackaging

    public init(
        site:
            StaticSiteDocumentMaterialization<Page>,
        dependencies:
            StaticDependencyPackaging
    ) {
        self.site =
            site

        self.dependencies =
            dependencies
    }
}
