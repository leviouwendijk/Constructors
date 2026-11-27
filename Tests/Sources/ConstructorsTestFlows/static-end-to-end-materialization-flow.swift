import CSS
import Constructors
import DSL
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
                        paths:
                            ArtifactPathProfile(
                                document:
                                    .init(
                                        .remainder(
                                            ArtifactPathProfile.route
                                        ),
                                        .literal(
                                            "page.html"
                                        )
                                    ),
                                stylesheet:
                                    .init(
                                        .literal(
                                            "static"
                                        ),
                                        .literal(
                                            "application.css"
                                        )
                                    )
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
                                "static/application.css"
                            )
                            .standardizedFileURL
                            .path,
                    ],
                    "static-end-to-end.document-policy-forwarded"
                )

                try Expect.equal(
                    prepared
                        .tree
                        .entries
                        .map {
                            $0
                                .path
                                .rendered(
                                    asRootPath:
                                        false
                                )
                        },
                    [
                        "page.html",
                        "contact/page.html",
                        "static/application.css",
                    ],
                    "static-end-to-end.tree-matches-materialized-paths"
                )

                try Expect.equal(
                    try prepared
                        .tree
                        .href(
                            for:
                                .stylesheet(
                                    .site
                                )
                        ),
                    "/static/application.css",
                    "static-end-to-end.tree-href"
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
                "catalogued assets and bundled scripts reach the tree with derived links"
            ) {
                let catalog =
                    try ArtifactAssetCatalog(
                        [
                            (
                                .init(rawValue: "images/logo"),
                                .bytes(Data([137, 80, 78, 71]), extension: "png")
                            ),
                            (
                                .init(rawValue: "images/unused"),
                                .bytes(Data([1]), extension: "png")
                            ),
                        ],
                        profile:
                            .init(hashesAssetNames: true)
                    )

                let rendered =
                    try endToEndRenderedSite(
                        policy:
                            .init(assets: catalog)
                    )

                let prepared =
                    try StaticSiteMaterializer(
                        policy:
                            .init(
                                paths: .init(hashesAssetNames: true),
                                scripts: .bundled,
                                assets: .init(catalog: catalog, emission: .used)
                            )
                    )
                    .prepare(
                        rendered
                    )

                let logo = try Expect.notNil(catalog.entry(.init(rawValue: "images/logo")), "static-end-to-end.catalog-logo")
                let paths = prepared.tree.entries.map { $0.path.rendered(asRootPath: false) }

                try Expect.true(paths.contains(logo.path.rendered(asRootPath: false)), "static-end-to-end.used-asset-emitted")
                try Expect.true(!paths.contains { $0.contains("unused") }, "static-end-to-end.unused-asset-pruned")
                try Expect.true(paths.contains("assets/js/site.js"), "static-end-to-end.bundled-script-file")

                let home = try Expect.notNil(
                    prepared.documents.first { $0.identifier.rawValue == "home" },
                    "static-end-to-end.home"
                )
                try Expect.true(home.contents.contains(try catalog.href(.init(rawValue: "images/logo"))), "static-end-to-end.asset-href-derived")
                try Expect.true(home.contents.contains("/assets/js/site.js"), "static-end-to-end.script-href-derived")
                try Expect.equal(
                    try prepared.tree.bytes(for: .asset(.init(rawValue: "images/logo"))),
                    Data([137, 80, 78, 71]),
                    "static-end-to-end.asset-bytes"
                )
            }

            Step(
                "the site head is declared once and every URL in it is derived"
            ) {
                let icon = StructuredContent.AssetKey(rawValue: "images/icon")
                let catalog =
                    try ArtifactAssetCatalog(
                        [
                            (icon, .bytes(Data([1, 2]), extension: "png")),
                            (.init(rawValue: "images/logo"), .bytes(Data([3]), extension: "png")),
                        ]
                    )

                let prepared =
                    try StaticSiteMaterializer(
                        policy:
                            .init(
                                paths: .standard,
                                assets: .init(catalog: catalog, emission: .used),
                                head: SiteHead(
                                    siteName: "Fixture",
                                    description: "A fixture site.",
                                    canonicalBase: URL(string: "https://example.com/"),
                                    language: "nl",
                                    icon: icon,
                                    themeColor: ThemeColor(css: "#0a63c9")
                                )
                            )
                    )
                    .prepare(
                        try endToEndRenderedSite(
                            policy: .init(assets: catalog)
                        )
                    )

                let contact = try Expect.notNil(
                    prepared.documents.first { $0.identifier.rawValue == "contact" },
                    "static-end-to-end.head.contact"
                ).contents

                try Expect.true(contact.contains("https://example.com/contact/"), "static-end-to-end.head.canonical")
                try Expect.true(contact.contains("og:url"), "static-end-to-end.head.open-graph")
                try Expect.true(contact.contains(try catalog.href(icon)), "static-end-to-end.head.icon-href")
                try Expect.true(contact.contains("lang=\"nl\""), "static-end-to-end.head.lang")
                try Expect.true(contact.contains("A fixture site."), "static-end-to-end.head.description")
                try Expect.true(contact.contains("#0a63c9"), "static-end-to-end.head.theme-color")
                try Expect.equal(
                    contact.components(separatedBy: "<title").count - 1,
                    1,
                    "static-end-to-end.head.page-title-kept-once"
                )
                try Expect.true(
                    prepared.tree.entries.contains { $0.key == .asset(icon) },
                    "static-end-to-end.head.icon-exported-under-used"
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

private func endToEndRenderedSite(
    policy:
        SiteRenderingPolicy = .init()
)
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
                projection,
            policy:
                policy
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
                context
                in

                try endToEndOutput(
                    page:
                        projectedPage,
                    state:
                        state,
                    context:
                        context
                )
            }
}

private func endToEndOutput(
    page:
        PageProjection<EndToEndPage>,
    state:
        EndToEndState,
    context:
        RenderContext<EndToEndPage>
) throws -> PageRenderOutput {
    let logo =
        StructuredContent.AssetKey(
            rawValue:
                "images/logo"
        )

    let usesLogo =
        page.identifier.rawValue == "home"
            && context.policy.assets.entry(logo) != nil

    let logoNodes: HTMLFragment =
        usesLogo
            ? [
                HTML.img(
                    src: try context.href(asset: logo),
                    alt: "Logo"
                ),
            ]
            : []

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
                            JSContributionIdentifier(
                                rawValue:
                                    "pipeline-home"
                            ),
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
                            JSContributionIdentifier(
                                rawValue:
                                    "pipeline-contact"
                            ),
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
                    ] + logoNodes
                ),
            styles:
                CSSContributions(
                    [
                        endToEndStyle(),
                    ]
                ),
            scripts:
                scripts,
            assets:
                usesLogo ? [logo] : []
        )
}

private func endToEndStyle()
    -> CSSContribution
{
    CSSContribution(
        identifier:
            CSSContributionIdentifier(
                rawValue:
                    "pipeline-style"
            ),
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
            JSContributionIdentifier(
                rawValue:
                    "pipeline-shared"
            ),
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
