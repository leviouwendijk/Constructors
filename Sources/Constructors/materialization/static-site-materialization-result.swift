/// Rich result of one complete static site materialization.
///
/// The result deliberately avoids storing duplicate copies of every
/// intermediate stage. `serialized` already owns the canonical nested chain:
///
///     serialized
///         -> integrated
///         -> packaged
///         -> document plan
///
/// Computed views expose those stages for diagnostics and downstream tooling.
///
/// `rendered` is retained because it is the semantic rendering input that
/// precedes the static lowering chain. `delivery` is retained because concrete
/// filesystem destinations exist only after writing.
public struct StaticSiteMaterializationResult<
    Page:
        PageGraphNode
>:
    Sendable
{
    public let rendered:
        SiteRenderResult<Page>

    public let serialized:
        StaticSerializedSiteMaterialization<Page>

    public let delivery:
        StaticFileWriteResult

    public init(
        rendered:
            SiteRenderResult<Page>,
        serialized:
            StaticSerializedSiteMaterialization<Page>,
        delivery:
            StaticFileWriteResult
    ) {
        self.rendered =
            rendered

        self.serialized =
            serialized

        self.delivery =
            delivery
    }

    public var integrated:
        StaticIntegratedSiteMaterializationPlan<Page>
    {
        serialized
            .source
    }

    public var packaged:
        StaticSiteMaterializationPlan<Page>
    {
        integrated
            .source
    }

    public var documentPlan:
        StaticSiteDocumentMaterialization<Page>
    {
        packaged
            .site
    }

    public var artifacts:
        [StaticTextArtifact]
    {
        serialized
            .artifacts
    }
}
