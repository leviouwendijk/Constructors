import Foundation

/// Caller-facing orchestration of the complete static materialization branch.
///
/// This type does not replace any stage. It simply executes their established
/// contracts in order:
///
///     SiteRenderResult
///         -> StaticDocumentMaterializer
///         -> StaticDependencyPackager
///         -> StaticDocumentDependencyIntegrator
///         -> StaticSiteSerializer
///         -> StaticFileWriter
///
/// `prepare(_:)` intentionally stops before filesystem mutation. This allows
/// callers to inspect the complete serialized artifact set before choosing a
/// delivery mechanism.
///
/// `materialize` adds filesystem delivery through an explicitly supplied
/// `StaticFileWriter` or an explicitly supplied output-root URL.
public struct StaticSiteMaterializer:
    Sendable
{
    public let policy:
        StaticSiteMaterializationPolicy

    public init(
        policy:
            StaticSiteMaterializationPolicy =
                .init()
    ) {
        self.policy =
            policy
    }

    /// Execute every static transformation through terminal serialization but
    /// do not perform filesystem delivery.
    public func prepare<
        Page:
            PageGraphNode
    >(
        _ rendered:
            SiteRenderResult<Page>
    ) throws -> StaticSerializedSiteMaterialization<Page> {
        let documents =
            StaticDocumentMaterializer(
                policy:
                    policy
                        .documents
            )
            .materialize(
                rendered
            )

        let packaged =
            StaticDependencyPackager(
                policy:
                    policy
                        .dependencies
            )
            .pack(
                documents
            )

        let integrated =
            try StaticDocumentDependencyIntegrator(
                policy:
                    policy
                        .integration
            )
            .integrate(
                packaged
            )

        return
            StaticSiteSerializer(
                policy:
                    policy
                        .serialization
            )
            .serialize(
                integrated
            )
    }

    /// Prepare and deliver a rendered site through a caller-owned writer.
    ///
    /// Supplying the writer keeps output-root ownership at the delivery
    /// boundary and leaves this orchestration object reusable.
    public func materialize<
        Page:
            PageGraphNode
    >(
        _ rendered:
            SiteRenderResult<Page>,
        using writer:
            StaticFileWriter
    ) throws -> StaticSiteMaterializationResult<Page> {
        let serialized =
            try prepare(
                rendered
            )

        let delivery =
            try writer
                .write(
                    serialized
                        .artifacts
                )

        return
            StaticSiteMaterializationResult(
                rendered:
                    rendered,
                serialized:
                    serialized,
                delivery:
                    delivery
            )
    }

    /// Convenience filesystem delivery when the caller has an output root
    /// rather than a preconstructed writer.
    public func materialize<
        Page:
            PageGraphNode
    >(
        _ rendered:
            SiteRenderResult<Page>,
        to root:
            URL
    ) throws -> StaticSiteMaterializationResult<Page> {
        try materialize(
            rendered,
            using:
                StaticFileWriter(
                    root:
                        root
                )
        )
    }
}
