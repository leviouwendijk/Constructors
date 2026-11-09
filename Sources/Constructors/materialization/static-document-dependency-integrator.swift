import HTML
import JS
import Primitives

public enum StaticDocumentDependencyIntegrationError:
    Error,
    Sendable,
    Equatable
{
    case missingPackagedScript(
        String
    )

    case packagedScriptMismatch(
        String
    )
}

/// Connect static dependency packaging to each still-structural HTML document.
///
/// Site-level packaging remains the canonical packaged representation, while
/// each `StaticDocumentArtifact` remains authoritative for which scripts belong
/// to that document and in which order.
///
/// No HTML string manipulation occurs here.
public struct StaticDocumentDependencyIntegrator:
    Sendable
{
    public let policy:
        StaticDocumentDependencyIntegrationPolicy

    public init(
        policy:
            StaticDocumentDependencyIntegrationPolicy =
                .init()
    ) {
        self.policy =
            policy
    }

    public func integrate<
        Identifier:
            StringIdentifier
    >(
        _ artifact:
            StaticDocumentArtifact<Identifier>,
        packaging:
            StaticDependencyPackaging
    ) throws -> StaticIntegratedDocumentArtifact<Identifier> {
        var document =
            artifact
                .document

        let stylesheet =
            StaticStylesheetDocumentReference(
                output:
                    packaging
                        .stylesheet
                        .output,
                href:
                    policy
                        .stylesheetHref
            )

        document
            .head
            .append(
                HTML.stylesheet(
                    href:
                        stylesheet
                            .href
                )
            )

        let scripts =
            try artifact
                .dependencies
                .scripts
                .contributions
                .map { contribution in
                    guard
                        let packaged =
                            packaging
                                .scripts
                                .first(
                                    where: {
                                        $0
                                            .identifier
                                            == contribution
                                                .identifier
                                    }
                                )
                    else {
                        throw
                            StaticDocumentDependencyIntegrationError
                                .missingPackagedScript(
                                    contribution
                                        .identifier
                                        .rawValue
                                )
                    }

                    guard
                        packaged
                            .scope
                            == contribution
                                .scope,
                        packaged
                            .script
                            == contribution
                                .script
                    else {
                        throw
                            StaticDocumentDependencyIntegrationError
                                .packagedScriptMismatch(
                                    contribution
                                        .identifier
                                        .rawValue
                                )
                    }

                    integrate(
                        packaged,
                        into:
                            &document
                    )

                    return
                        packaged
                }

        return
            StaticIntegratedDocumentArtifact(
                source:
                    artifact,
                document:
                    document,
                stylesheet:
                    stylesheet,
                scripts:
                    scripts
            )
    }

    public func integrate<
        Page:
            PageGraphNode
    >(
        _ plan:
            StaticSiteMaterializationPlan<Page>
    ) throws -> StaticIntegratedSiteMaterializationPlan<Page> {
        StaticIntegratedSiteMaterializationPlan(
            source:
                plan,
            documents:
                try plan
                    .site
                    .documents
                    .map { document in
                        try integrate(
                            document,
                            packaging:
                                plan
                                    .dependencies
                        )
                    }
        )
    }

    private func integrate(
        _ dependency:
            StaticJavaScriptDependency,
        into document:
            inout HTMLDocument
    ) {
        let placement:
            StaticJavaScriptDocumentPlacement

        switch dependency.script {
        case .inline:
            placement =
                policy
                    .inlineScriptPlacement

        case .external:
            placement =
                policy
                    .externalScriptPlacement
        }

        let node =
            HTML.script(
                dependency
                    .script
            )

        switch placement {
        case .headEnd:
            document
                .head
                .append(
                    node
                )

        case .bodyEnd:
            document
                .body
                .append(
                    node
                )
        }
    }
}
