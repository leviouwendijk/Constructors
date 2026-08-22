import CSS
import Constructors
import Foundation
import HTML
import JS
import Path
import Primitives
import TestFlows

extension ConstructorsFlowSuite {
    static let staticEndToEndMaterialization =
        TestFlow(
            "static-end-to-end-materialization",
            title:
                "Static orchestration carries a projected rendered site through structural planning, packaging, integration, serialization, and real filesystem delivery",
            tags: [
                "constructors",
                "end-to-end",
                "materialization",
                "orchestration",
                "rendering",
                "serialization",
                "static",
                "writer",
            ]
        ) {
            Step(
                "write-free preparation composes document planning packaging integration and serialization while retaining provenance"
            ) {
                let rendered =
                    try endToEndRenderedSite()

                let root =
                    endToEndTemporaryRoot(
                        "prepare"
                    )

                defer {
                    try?
                        FileManager
                            .default
                            .removeItem(
                                at:
                                    root
                            )
                }

                let prepared =
                    try StaticSiteMaterializer()
                        .prepare(
                            rendered
                        )

                try Expect.equal(
                    FileManager
                        .default
                        .fileExists(
                            atPath:
                                root
                                    .path
                        ),
                    false,
                    "static-end-to-end.prepare-is-write-free"
                )

                try Expect.equal(
                    prepared
                        .documents
                        .count,
                    2,
                    "static-end-to-end.prepared-document-count"
                )

                try Expect.equal(
                    prepared
                        .artifacts
                        .count,
                    3,
                    "static-end-to-end.prepared-artifact-count"
                )

                try Expect.equal(
                    prepared
                        .artifacts
                        .map {
                            $0
                                .output
                                .url(
                                    base:
                                        root
                                )
                                .standardizedFileURL
                                .path
                        },
                    [
                        root
                            .appendingPathComponent(
                                "index.html"
                            )
                            .standardizedFileURL
                            .path,
                        root
                            .appendingPathComponent(
                                "contact/index.html"
                            )
                            .standardizedFileURL
                            .path,
                        root
                            .appendingPathComponent(
                                "assets/css/site.css"
                            )
                            .standardizedFileURL
                            .path,
                    ],
                    "static-end-to-end.default-output-plan"
                )

                try Expect.equal(
                    prepared
                        .stylesheet
                        .source
                        .sourceContributionIdentifiers
                        .map(
                            \.rawValue
                        ),
                    [
                        "pipeline-style",
                    ],
                    "static-end-to-end.site-css-deduplicated-with-provenance"
                )

                let scriptOrder =
                    Dictionary(
                        uniqueKeysWithValues:
                            prepared
                                .source
                                .documents
                                .map { document in
                                    (
                                        document
                                            .identifier
                                            .rawValue,
                                        document
                                            .scripts
                                            .map {
                                                $0
                                                    .identifier
                                                    .rawValue
                                            }
                                    )
                                }
                    )

                try Expect.equal(
                    scriptOrder[
                        "home"
                    ],
                    [
                        "pipeline-shared",
                        "pipeline-home",
                    ],
                    "static-end-to-end.home-local-script-order"
                )

                try Expect.equal(
                    scriptOrder[
                        "contact"
                    ],
                    [
                        "pipeline-contact",
                        "pipeline-shared",
                    ],
                    "static-end-to-end.contact-local-script-order"
                )

                try Expect.equal(
                    rendered
                        .documents
                        .count,
                    prepared
                        .source
                        .source
                        .site
                        .documents
                        .count,
                    "static-end-to-end.rendered-to-document-plan-cardinality"
                )
            }

            Step(
                "caller-owned writer delivers the prepared artifact set to real files without hiding the output root"
            ) {
                let rendered =
                    try endToEndRenderedSite()

                let root =
                    endToEndTemporaryRoot(
                        "writer"
                    )

                defer {
                    try?
                        FileManager
                            .default
                            .removeItem(
                                at:
                                    root
                            )
                }

                let writer =
                    try StaticFileWriter(
                        root:
                            root
                    )

                let result =
                    try StaticSiteMaterializer()
                        .materialize(
                            rendered,
                            using:
                                writer
                        )

                try Expect.equal(
                    result
                        .delivery
                        .root,
                    root
                        .standardizedFileURL,
                    "static-end-to-end.explicit-writer-root-retained"
                )

                try Expect.equal(
                    result
                        .delivery
                        .written
                        .count,
                    3,
                    "static-end-to-end.written-artifact-count"
                )

                try Expect.equal(
                    result
                        .delivery
                        .destinations,
                    result
                        .artifacts
                        .map {
                            $0
                                .output
                                .url(
                                    base:
                                        root
                                )
                                .standardizedFileURL
                        },
                    "static-end-to-end.delivery-matches-serialized-artifacts"
                )

                try Expect.equal(
                    result
                        .rendered
                        .documents
                        .count,
                    2,
                    "static-end-to-end.result-retains-rendered-input"
                )

                try Expect.equal(
                    result
                        .documentPlan
                        .documents
                        .count,
                    2,
                    "static-end-to-end.result-exposes-document-plan"
                )

                try Expect.equal(
                    result
                        .packaged
                        .dependencies
                        .stylesheet
                        .sourceContributionIdentifiers
                        .map(
                            \.rawValue
                        ),
                    [
                        "pipeline-style",
                    ],
                    "static-end-to-end.result-exposes-packaged-provenance"
                )

                try Expect.equal(
                    result
                        .integrated
                        .documents
                        .count,
                    2,
                    "static-end-to-end.result-exposes-integrated-plan"
                )

                let home =
                    try endToEndRead(
                        root
                            .appendingPathComponent(
                                "index.html"
                            )
                    )

                let contact =
                    try endToEndRead(
                        root
                            .appendingPathComponent(
                                "contact/index.html"
                            )
                    )

                let css =
                    try endToEndRead(
                        root
                            .appendingPathComponent(
                                "assets/css/site.css"
                            )
                    )

                for required in [
                    "Pipeline Home",
                    "state-home",
                    "/assets/css/site.css",
                    "window.pipelineShared = true;",
                    "window.pipelineHome = true;",
                ] {
                    try Expect.equal(
                        home
                            .contains(
                                required
                            ),
                        true,
                        "static-end-to-end.home-\(required)"
                    )
                }

                try Expect.equal(
                    home
                        .contains(
                            "window.pipelineContact = true;"
                        ),
                    false,
                    "static-end-to-end.home-excludes-contact-script"
                )

                for required in [
                    "Pipeline Contact",
                    "state-contact",
                    "/assets/css/site.css",
                    "window.pipelineContact = true;",
                    "window.pipelineShared = true;",
                ] {
                    try Expect.equal(
                        contact
                            .contains(
                                required
                            ),
                        true,
                        "static-end-to-end.contact-\(required)"
                    )
                }

                try Expect.equal(
                    contact
                        .contains(
                            "window.pipelineHome = true;"
                        ),
                    false,
                    "static-end-to-end.contact-excludes-home-script"
                )

                try Expect.equal(
                    css
                        .contains(
                            ".pipeline-fixture"
                        ),
                    true,
                    "static-end-to-end.stylesheet-selector"
                )

                try Expect.equal(
                    css
                        .contains(
                            "display: block;"
                        ),
                    true,
                    "static-end-to-end.stylesheet-declaration"
                )
            }

            Step(
                "aggregate policy forwards stage-specific choices without absorbing their responsibilities"
            ) {
                let rendered =
                    try endToEndRenderedSite()

                let root =
                    endToEndTemporaryRoot(
                        "policy"
                    )

                defer {
                    try?
                        FileManager
                            .default
                            .removeItem(
                                at:
                                    root
                            )
                }

                let policy =
                    StaticSiteMaterializationPolicy(
                        documents:
                            StaticDocumentMaterializationPolicy(
                                indexBasename:
                                    "page"
                            ),
                        integration:
                            StaticDocumentDependencyIntegrationPolicy(
                                stylesheetHref:
                                    "/static/application.css"
                            ),
                        serialization:
                            StaticSerializationPolicy(
                                html:
                                    HTMLRenderOptions
                                        .Defaults
                                        .minified()
                            )
                    )

                let prepared =
                    try StaticSiteMaterializer(
                        policy:
                            policy
                    )
                    .prepare(
                        rendered
                    )

                try Expect.equal(
                    prepared
                        .artifacts
                        .map {
                            $0
                                .output
                                .url(
                                    base:
                                        root
                                )
                                .standardizedFileURL
                                .path
                        },
                    [
                        root
                            .appendingPathComponent(
                                "page.html"
                            )
                            .standardizedFileURL
                            .path,
                        root
                            .appendingPathComponent(
                                "contact/page.html"
                            )
                            .standardizedFileURL
                            .path,
                        root
                            .appendingPathComponent(
                                "assets/css/site.css"
                            )
                            .standardizedFileURL
                            .path,
                    ],
                    "static-end-to-end.document-policy-forwarded"
                )

                for document in prepared
                    .documents
                {
                    try Expect.equal(
                        document
                            .contents
                            .contains(
                                "/static/application.css"
                            ),
                        true,
                        "static-end-to-end.integration-policy-forwarded-\(document.identifier.rawValue)"
                    )

                    try Expect.equal(
                        document
                            .contents
                            .contains(
                                "/assets/css/site.css"
                            ),
                        false,
                        "static-end-to-end.default-stylesheet-href-replaced-\(document.identifier.rawValue)"
                    )

                    try Expect.equal(
                        document
                            .contents,
                        document
                            .source
                            .document
                            .render(
                                options:
                                    policy
                                        .serialization
                                        .html
                            ),
                        "static-end-to-end.serialization-policy-forwarded-\(document.identifier.rawValue)"
                    )
                }

                try Expect.equal(
                    FileManager
                        .default
                        .fileExists(
                            atPath:
                                root
                                    .path
                        ),
                    false,
                    "static-end-to-end.custom-policy-prepare-remains-write-free"
                )
            }

            Step(
                "root convenience materialization reaches the same complete static delivery boundary"
            ) {
                let rendered =
                    try endToEndRenderedSite()

                let root =
                    endToEndTemporaryRoot(
                        "root-convenience"
                    )

                defer {
                    try?
                        FileManager
                            .default
                            .removeItem(
                                at:
                                    root
                            )
                }

                let result =
                    try StaticSiteMaterializer()
                        .materialize(
                            rendered,
                            to:
                                root
                        )

                try Expect.equal(
                    result
                        .delivery
                        .root,
                    root
                        .standardizedFileURL,
                    "static-end-to-end.root-convenience-delivery-root"
                )

                try Expect.equal(
                    result
                        .delivery
                        .written
                        .count,
                    result
                        .artifacts
                        .count,
                    "static-end-to-end.root-convenience-complete-delivery"
                )

                for destination in result
                    .delivery
                    .destinations
                {
                    try Expect.equal(
                        FileManager
                            .default
                            .fileExists(
                                atPath:
                                    destination
                                        .path
                            ),
                        true,
                        "static-end-to-end.root-convenience-file-exists-\(destination.lastPathComponent)"
                    )
                }
            }
        }
}

private func endToEndRenderedSite()
    throws -> SiteRenderResult<
        EndToEndPage
    >
{
    let projection =
        try endToEndGraph()
            .resolve()
            .project(
                in:
                    .public
            )

    let context =
        RenderContext(
            projection:
                projection
        )

    let state =
        EndToEndState(
            markerPrefix:
                "state"
        )

    return
        try context
            .renderSite(
                state:
                    state
            ) {
                projectedPage,
                state,
                _
                in

                endToEndOutput(
                    page:
                        projectedPage,
                    state:
                        state
                )
            }
}

private func endToEndOutput(
    page:
        PageProjection<EndToEndPage>,
    state:
        EndToEndState
) -> PageRenderOutput {
    let identifier =
        page
            .identifier
            .rawValue

    let scripts:
        JSContributions

    switch identifier {
    case "home":
        scripts =
            JSContributions(
                [
                    endToEndSharedScript(),
                    JSContribution(
                        identifier:
                            "pipeline-home",
                        script:
                            .inline(
                                JSSource(
                                    "window.pipelineHome = true;"
                                )
                            )
                    ),
                ]
            )

    case "contact":
        scripts =
            JSContributions(
                [
                    JSContribution(
                        identifier:
                            "pipeline-contact",
                        script:
                            .inline(
                                JSSource(
                                    "window.pipelineContact = true;"
                                )
                            )
                    ),
                    endToEndSharedScript(),
                ]
            )

    default:
        scripts =
            JSContributions(
                [
                    endToEndSharedScript(),
                ]
            )
    }

    return
        PageRenderOutput(
            document:
                HTMLDocument(
                    attributes:
                        .empty,
                    head: [
                        HTML.title(
                            page
                                .page
                                .title
                        ),
                    ],
                    body: [
                        HTML.div(
                            [
                                "class":
                                    "pipeline-fixture",
                                "data-page":
                                    identifier,
                            ]
                        ) {
                            HTML.text(
                                "\(state.markerPrefix)-\(identifier)"
                            )
                        },
                    ]
                ),
            styles:
                CSSContributions(
                    [
                        endToEndStyle(),
                    ]
                ),
            scripts:
                scripts
        )
}

private func endToEndStyle()
    -> CSSContribution
{
    CSSContribution(
        identifier:
            "pipeline-style",
        content:
            CSSContributionSet {
                CSS.rule(
                    ".pipeline-fixture",
                    CSS.decl(
                        "display",
                        "block"
                    )
                )
            }
    )
}

private func endToEndSharedScript()
    -> JSContribution
{
    JSContribution(
        identifier:
            "pipeline-shared",
        script:
            .inline(
                JSSource(
                    "window.pipelineShared = true;"
                )
            )
    )
}

private func endToEndGraph()
    -> PageGraph<
        EndToEndPage
    >
{
    PageGraph(
        roots: [
            EndToEndPage(
                identifier:
                    "home",
                slug:
                    nil,
                title:
                    "Pipeline Home",
                children: [
                    EndToEndPage(
                        identifier:
                            "contact",
                        slug:
                            PathSegment(
                                "contact",
                                .directory
                            ),
                        title:
                            "Pipeline Contact"
                    ),
                ]
            ),
        ]
    )
}

private struct EndToEndState:
    Sendable
{
    let markerPrefix:
        String
}

private struct EndToEndPageIdentifier:
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

private struct EndToEndPage:
    PageGraphNode
{
    let identifier:
        EndToEndPageIdentifier

    let slug:
        PathSegment?

    let title:
        String

    let visibility:
        Set<BuildEnvironment>

    let children:
        [EndToEndPage]

    init(
        identifier:
            EndToEndPageIdentifier,
        slug:
            PathSegment?,
        title:
            String,
        visibility:
            Set<BuildEnvironment> = [
                .local,
                .test,
                .public,
            ],
        children:
            [EndToEndPage] = []
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

private func endToEndTemporaryRoot(
    _ label:
        String
) -> URL
{
    FileManager
        .default
        .temporaryDirectory
        .appendingPathComponent(
            "constructors-static-end-to-end-\(label)-\(UUID().uuidString)",
            isDirectory:
                true
        )
}

private func endToEndRead(
    _ url:
        URL
) throws -> String {
    let data =
        try Data(
            contentsOf:
                url
        )

    return
        String(
            decoding:
                data,
            as:
                UTF8
                    .self
        )
}
