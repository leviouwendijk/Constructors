import CSS
import Constructors
import HTML
import JS
import Path
import Primitives
import TestFlows

extension ConstructorsFlowSuite {
    static let staticTerminalSerialization =
        TestFlow(
            "static-terminal-serialization",
            title:
                "Terminal static serialization converts integrated HTML and packaged CSS into write-free text artifacts",
            tags: [
                "constructors",
                "css",
                "html",
                "materialization",
                "serialization",
                "static",
            ]
        ) {
            Step(
                "default serialization emits HTML only after stylesheet and script integration"
            ) {
                let integrated =
                    try serializationIntegratedFixture()

                let serialized =
                    StaticSiteSerializer()
                        .serialize(
                            integrated
                        )

                try Expect.equal(
                    serialized
                        .documents
                        .count,
                    1,
                    "static-serialization.document-count"
                )

                try Expect.equal(
                    serialized
                        .artifacts
                        .count,
                    2,
                    "static-serialization.generated-artifact-count"
                )

                guard
                    let document =
                        serialized
                            .documents
                            .first
                else {
                    throw
                        StaticSerializationFlowFailure
                            .missingDocument
                }

                let html =
                    document
                        .contents

                for required in [
                    "Serialization Fixture",
                    "/assets/css/site.css",
                    "window.serializationInline = true;",
                    "/assets/serialization-external.js",
                    "type=\"module\"",
                    "nonce=\"serialization-inline-nonce\"",
                    "defer",
                    "integrity=\"sha256-serialization-fixture\"",
                    "crossorigin=\"anonymous\"",
                    "nonce=\"serialization-external-nonce\"",
                ] {
                    try Expect.equal(
                        html
                            .contains(
                                required
                            ),
                        true,
                        "static-serialization.integrated-html-\(required)"
                    )
                }

                try Expect.equal(
                    document
                        .artifact
                        .output,
                    integrated
                        .documents[0]
                        .output,
                    "static-serialization.document-output-preserved"
                )

                try Expect.equal(
                    serialized
                        .stylesheet
                        .artifact
                        .output,
                    integrated
                        .source
                        .dependencies
                        .stylesheet
                        .output,
                    "static-serialization.stylesheet-output-preserved"
                )

                try Expect.equal(
                    serialized
                        .artifacts
                        .map {
                            $0
                                .output
                        },
                    [
                        document
                            .output,
                        serialized
                            .stylesheet
                            .output,
                    ],
                    "static-serialization.complete-generated-output-set"
                )
            }

            Step(
                "stylesheet serialization happens at the same terminal frontier while contribution provenance survives outside CSS text"
            ) {
                let integrated =
                    try serializationIntegratedFixture()

                let serialized =
                    StaticSiteSerializer()
                        .serialize(
                            integrated
                        )

                let css =
                    serialized
                        .stylesheet
                        .contents

                try Expect.equal(
                    css
                        .contains(
                            ".serialization-fixture {"
                        ),
                    true,
                    "static-serialization.css-selector"
                )

                try Expect.equal(
                    css
                        .contains(
                            "    display: block;"
                        ),
                    true,
                    "static-serialization.default-css-indentation"
                )

                try Expect.equal(
                    serialized
                        .stylesheet
                        .source
                        .sourceContributionIdentifiers
                        .map(
                            \.rawValue
                        ),
                    [
                        "serialization-style",
                    ],
                    "static-serialization.css-provenance-retained"
                )

                guard
                    let document =
                        serialized
                            .documents
                            .first
                else {
                    throw
                        StaticSerializationFlowFailure
                            .missingDocument
                }

                try Expect.equal(
                    document
                        .source
                        .scripts
                        .map {
                            $0
                                .identifier
                                .rawValue
                        },
                    [
                        "serialization-inline",
                        "serialization-external",
                    ],
                    "static-serialization.js-provenance-retained"
                )
            }

            Step(
                "serialization policy changes textual representation without changing physical artifact identity"
            ) {
                let integrated =
                    try serializationIntegratedFixture()

                let defaults =
                    StaticSiteSerializer()
                        .serialize(
                            integrated
                        )

                let compactPolicy =
                    StaticSerializationPolicy(
                        html:
                            HTMLRenderOptions
                                .Defaults
                                .minified(),
                        stylesheet:
                            CSSRenderOptions(
                                indentStep:
                                    2,
                                ensureTrailingNewline:
                                    true,
                                mergeDuplicateSelectors:
                                    false
                            )
                    )

                let compact =
                    StaticSiteSerializer(
                        policy:
                            compactPolicy
                    )
                    .serialize(
                        integrated
                    )

                guard
                    let defaultDocument =
                        defaults
                            .documents
                            .first,
                    let compactDocument =
                        compact
                            .documents
                            .first,
                    let integratedDocument =
                        integrated
                            .documents
                            .first
                else {
                    throw
                        StaticSerializationFlowFailure
                            .missingDocument
                }

                try Expect.equal(
                    compactDocument
                        .contents,
                    integratedDocument
                        .document
                        .render(
                            options:
                                compactPolicy
                                    .html
                        ),
                    "static-serialization.html-owning-serializer"
                )

                try Expect.equal(
                    compact
                        .stylesheet
                        .contents,
                    integrated
                        .source
                        .dependencies
                        .stylesheet
                        .stylesheet
                        .render(
                            options:
                                compactPolicy
                                    .stylesheet
                        ),
                    "static-serialization.css-owning-serializer"
                )

                try Expect.equal(
                    defaultDocument
                        .output,
                    compactDocument
                        .output,
                    "static-serialization.html-policy-does-not-change-output"
                )

                try Expect.equal(
                    defaults
                        .stylesheet
                        .output,
                    compact
                        .stylesheet
                        .output,
                    "static-serialization.css-policy-does-not-change-output"
                )

                try Expect.equal(
                    defaultDocument
                        .contents
                        == compactDocument
                            .contents,
                    false,
                    "static-serialization.html-representation-policy-effective"
                )

                try Expect.equal(
                    defaults
                        .stylesheet
                        .contents
                        == compact
                            .stylesheet
                            .contents,
                    false,
                    "static-serialization.css-representation-policy-effective"
                )

                try Expect.equal(
                    compact
                        .stylesheet
                        .contents
                        .contains(
                            "\n  display: block;"
                        ),
                    true,
                    "static-serialization.custom-css-indentation"
                )
            }

            Step(
                "external JavaScript remains a reference and inline JavaScript remains inside HTML rather than becoming generated artifacts"
            ) {
                let integrated =
                    try serializationIntegratedFixture()

                let serialized =
                    StaticSiteSerializer()
                        .serialize(
                            integrated
                        )

                guard
                    let document =
                        serialized
                            .documents
                            .first
                else {
                    throw
                        StaticSerializationFlowFailure
                            .missingDocument
                }

                try Expect.equal(
                    serialized
                        .artifacts
                        .count,
                    serialized
                        .documents
                        .count
                        + 1,
                    "static-serialization.no-generated-js-artifacts"
                )

                try Expect.equal(
                    document
                        .contents
                        .contains(
                            "window.serializationInline = true;"
                        ),
                    true,
                    "static-serialization.inline-js-in-html"
                )

                try Expect.equal(
                    document
                        .contents
                        .contains(
                            "/assets/serialization-external.js"
                        ),
                    true,
                    "static-serialization.external-js-remains-reference"
                )

                try Expect.equal(
                    document
                        .source
                        .scripts
                        .count,
                    2,
                    "static-serialization.script-structure-still-available-as-provenance"
                )
            }
        }
}

private func serializationIntegratedFixture()
    throws -> StaticIntegratedSiteMaterializationPlan<
        SerializationPage
    >
{
    let projection =
        try serializationGraph()
            .resolve()
            .project(
                in:
                    .public
            )

    guard
        let home =
            projection[
                "home"
            ]
    else {
        throw
            StaticSerializationFlowFailure
                .missingPage
    }

    let dependencies =
        try serializationDependencies()

    let rendered =
        try SiteRenderResult(
            projection:
                projection,
            documents: [
                RenderedDocument(
                    projectedPage:
                        home,
                    document:
                        HTMLDocument(
                            attributes:
                                .empty,
                            head: [
                                HTML.title(
                                    "Serialization Fixture"
                                ),
                            ],
                            body:
                                []
                        ),
                    dependencies:
                        dependencies
                ),
            ]
        )

    let documentPlan =
        StaticDocumentMaterializer()
            .materialize(
                rendered
            )

    let packaged =
        StaticDependencyPackager()
            .pack(
                documentPlan
            )

    return
        try StaticDocumentDependencyIntegrator()
            .integrate(
                packaged
            )
}

private func serializationDependencies()
    throws -> RenderDependencies
{
    let stylesheet =
        CSSContribution(
            identifier:
                "serialization-style",
            content:
                CSSContributionSet {
                    CSS.rule(
                        ".serialization-fixture",
                        CSS.decl(
                            "display",
                            "block"
                        )
                    )
                }
        )

    let inline =
        JSContribution(
            identifier:
                "serialization-inline",
            script:
                .inline(
                    JSSource(
                        "window.serializationInline = true;"
                    ),
                    attributes:
                        JSScriptAttributes(
                            kind:
                                .module,
                            nonce:
                                "serialization-inline-nonce"
                        )
                )
        )

    let external =
        JSContribution(
            identifier:
                "serialization-external",
            script:
                .external(
                    JSExternalSource(
                        "/assets/serialization-external.js"
                    ),
                    attributes:
                        JSScriptAttributes(
                            defer_loading:
                                true,
                            integrity:
                                "sha256-serialization-fixture",
                            crossorigin:
                                "anonymous",
                            nonce:
                                "serialization-external-nonce"
                        )
                )
        )

    return
        RenderDependencies(
            styles:
                try CSSContributions(
                    [
                        stylesheet,
                    ]
                )
                .resolve(),
            scripts:
                try JSContributions(
                    [
                        inline,
                        external,
                    ]
                )
                .resolve()
        )
}

private func serializationGraph()
    -> PageGraph<
        SerializationPage
    >
{
    PageGraph(
        roots: [
            SerializationPage(
                identifier:
                    "home",
                slug:
                    nil,
                title:
                    "Home"
            ),
        ]
    )
}

private struct SerializationPageIdentifier:
    StringIdentifier
{
    let rawValue:
        String

    init(
        rawValue:
            String
    ) {
        self.rawValue =
            rawValue
    }
}

private struct SerializationPage:
    PageGraphNode
{
    let identifier:
        SerializationPageIdentifier

    let slug:
        PathSegment?

    let title:
        String

    let visibility:
        Set<BuildEnvironment>

    let children:
        [SerializationPage]

    init(
        identifier:
            SerializationPageIdentifier,
        slug:
            PathSegment?,
        title:
            String,
        visibility:
            Set<BuildEnvironment> = [
                .public,
            ],
        children:
            [SerializationPage] = []
    ) {
        self.identifier =
            identifier

        self.slug =
            slug

        self.title =
            title

        self.visibility =
            visibility

        self.children =
            children
    }
}

private enum StaticSerializationFlowFailure:
    Error
{
    case missingPage
    case missingDocument
}
