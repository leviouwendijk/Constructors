import CSS
import Constructors
import HTML
import JS
import Path
import Primitives
import TestFlows

extension ConstructorsFlowSuite {
    static let staticDocumentMaterialization =
        TestFlow(
            "static-document-materialization",
            title:
                "Static document materialization establishes physical HTML artifacts only after rendering",
            tags: [
                "constructors",
                "html",
                "materialization",
                "path",
                "serialization",
                "static",
            ]
        ) {
            Step(
                "logical root and nested routes become physical index HTML outputs"
            ) {
                let rendered =
                    try materializationRenderedSite()

                let materialized =
                    StaticDocumentMaterializer()
                        .materialize(
                            rendered
                        )

                guard
                    let home =
                        materialized
                            .documents
                            .first(
                                where: {
                                    $0
                                        .identifier
                                        .rawValue
                                        == "home"
                                }
                            )
                else {
                    throw
                        StaticMaterializationFlowFailure
                            .missingHome
                }

                guard
                    let contact =
                        materialized
                            .documents
                            .first(
                                where: {
                                    $0
                                        .identifier
                                        .rawValue
                                        == "contact"
                                }
                            )
                else {
                    throw
                        StaticMaterializationFlowFailure
                            .missingContact
                }

                try Expect.equal(
                    home.output,
                    StandardPath(
                        [
                            "index",
                        ],
                        filetype:
                            .text(
                                .html
                            )
                    ),
                    "static-materialization.root-output"
                )

                try Expect.equal(
                    contact.output,
                    StandardPath(
                        [
                            "contact",
                            "index",
                        ],
                        filetype:
                            .text(
                                .html
                            )
                    ),
                    "static-materialization.nested-output"
                )

                try Expect.equal(
                    home.route.href,
                    "/",
                    "static-materialization.root-route-retained"
                )

                try Expect.equal(
                    contact.route.href,
                    "/contact/",
                    "static-materialization.nested-route-retained"
                )
            }

            Step(
                "HTML serialization occurs at the static document materialization boundary"
            ) {
                let projection =
                    try materializationGraph()
                        .project(
                            in:
                                .public
                        )

                let context =
                    RenderContext(
                        projection:
                            projection
                    )

                let rendered =
                    try context
                        .render(
                            page:
                                "home"
                        ) {
                            _,
                            _
                            in

                            PageRenderOutput(
                                document:
                                    materializationDocument()
                            )
                        }

                let prettyPolicy =
                    StaticDocumentMaterializationPolicy(
                        html:
                            HTMLRenderOptions
                                .Defaults
                                .pretty()
                    )

                let minifiedPolicy =
                    StaticDocumentMaterializationPolicy(
                        html:
                            HTMLRenderOptions
                                .Defaults
                                .minified()
                    )

                let pretty =
                    StaticDocumentMaterializer(
                        policy:
                            prettyPolicy
                    )
                    .materialize(
                        rendered
                    )

                let minified =
                    StaticDocumentMaterializer(
                        policy:
                            minifiedPolicy
                    )
                    .materialize(
                        rendered
                    )

                try Expect.equal(
                    pretty.serializedHTML,
                    rendered
                        .document
                        .render(
                            options:
                                HTMLRenderOptions
                                    .Defaults
                                    .pretty()
                        ),
                    "static-materialization.pretty-terminal-serialization"
                )

                try Expect.equal(
                    minified.serializedHTML,
                    rendered
                        .document
                        .render(
                            options:
                                HTMLRenderOptions
                                    .Defaults
                                    .minified()
                        ),
                    "static-materialization.minified-terminal-serialization"
                )

                try Expect.equal(
                    pretty.output,
                    minified.output,
                    "static-materialization.serialization-does-not-change-output-identity"
                )
            }

            Step(
                "materialized artifacts preserve semantic page provenance"
            ) {
                let rendered =
                    try materializationRenderedSite()

                let materialized =
                    StaticDocumentMaterializer()
                        .materialize(
                            rendered
                        )

                try Expect.equal(
                    materialized
                        .documents
                        .map {
                            $0
                                .identifier
                                .rawValue
                        },
                    [
                        "home",
                        "contact",
                    ],
                    "static-materialization.identifiers-retained"
                )

                try Expect.equal(
                    materialized
                        .documents
                        .map {
                            $0
                                .route
                                .href
                        },
                    [
                        "/",
                        "/contact/",
                    ],
                    "static-materialization.logical-routes-retained"
                )

                try Expect.equal(
                    materialized
                        .projection
                        .pages
                        .map {
                            $0
                                .identifier
                                .rawValue
                        },
                    [
                        "home",
                        "contact",
                    ],
                    "static-materialization.projection-retained"
                )
            }

            Step(
                "CSS and JavaScript dependencies remain resolved semantic values after document materialization"
            ) {
                let rendered =
                    try materializationRenderedSite()

                let materialized =
                    StaticDocumentMaterializer()
                        .materialize(
                            rendered
                        )

                try Expect.equal(
                    materialized.dependencies,
                    rendered.dependencies,
                    "static-materialization.dependencies-preserved"
                )

                try Expect.equal(
                    materialized
                        .dependencies
                        .styles
                        .identifiers
                        .map(
                            \.rawValue
                        ),
                    [
                        "materialization-style",
                    ],
                    "static-materialization.styles-remain-identified"
                )

                try Expect.equal(
                    materialized
                        .dependencies
                        .scripts
                        .identifiers
                        .map(
                            \.rawValue
                        ),
                    [
                        "materialization-script",
                    ],
                    "static-materialization.scripts-remain-identified"
                )
            }

            Step(
                "physical filename policy does not mutate logical route identity"
            ) {
                let projection =
                    try PageGraph(
                        roots: [
                            MaterializationPage(
                                identifier:
                                    "policy-root",
                                slug:
                                    nil,
                                title:
                                    "Policy Root",
                                children: [
                                    MaterializationPage(
                                        identifier:
                                            "account",
                                        slug:
                                            materializationSegment(
                                                "account"
                                            ),
                                        title:
                                            "Account",
                                        children: [
                                            MaterializationPage(
                                                identifier:
                                                    "agreement",
                                                slug:
                                                    materializationSegment(
                                                        "agreement"
                                                    ),
                                                title:
                                                    "Agreement"
                                            ),
                                        ]
                                    ),
                                ]
                            ),
                        ]
                    )
                    .project(
                        in:
                            .public
                    )

                guard
                    let agreement =
                        projection[
                            "agreement"
                        ]
                else {
                    throw
                        StaticMaterializationFlowFailure
                            .missingAgreement
                }

                let route =
                    agreement
                        .siteRoute

                let defaultPolicy =
                    StaticDocumentMaterializationPolicy()

                let customPolicy =
                    StaticDocumentMaterializationPolicy(
                        indexBasename:
                            "document"
                    )

                try Expect.equal(
                    defaultPolicy
                        .documentOutput(
                            for:
                                route
                        ),
                    StandardPath(
                        [
                            "account",
                            "agreement",
                            "index",
                        ],
                        filetype:
                            .text(
                                .html
                            )
                    ),
                    "static-materialization.default-index-policy"
                )

                try Expect.equal(
                    customPolicy
                        .documentOutput(
                            for:
                                route
                        ),
                    StandardPath(
                        [
                            "account",
                            "agreement",
                            "document",
                        ],
                        filetype:
                            .text(
                                .html
                            )
                    ),
                    "static-materialization.custom-index-policy"
                )

                try Expect.equal(
                    route.href,
                    "/account/agreement/",
                    "static-materialization.logical-route-independent-of-filename"
                )
            }
        }
}

private func materializationRenderedSite()
    throws
    -> SiteRenderResult<
        MaterializationPage
    >
{
    let projection =
        try materializationGraph()
            .project(
                in:
                    .public
            )

    let context =
        RenderContext(
            projection:
                projection
        )

    return
        try context
            .renderSite {
                _,
                _
                in

                PageRenderOutput(
                    document:
                        materializationDocument(),
                    styles:
                        CSSContributions(
                            [
                                CSSContribution(
                                    identifier:
                                        "materialization-style",
                                    content:
                                        CSSContributionSet(
                                            units:
                                                []
                                        )
                                ),
                            ]
                        ),
                    scripts:
                        JSContributions(
                            [
                                JSContribution(
                                    identifier:
                                        "materialization-script",
                                    script:
                                        .inline(
                                            JSSource(
                                                "window.materialization = true;"
                                            )
                                        )
                                ),
                            ]
                        )
                )
            }
}

private func materializationDocument()
    -> HTMLDocument
{
    HTMLDocument(
        attributes:
            .empty,
        head:
            [],
        body:
            []
    )
}

private func materializationGraph()
    -> PageGraph<
        MaterializationPage
    >
{
    PageGraph(
        roots: [
            MaterializationPage(
                identifier:
                    "home",
                slug:
                    nil,
                title:
                    "Home",
                children: [
                    MaterializationPage(
                        identifier:
                            "contact",
                        slug:
                            materializationSegment(
                                "contact"
                            ),
                        title:
                            "Contact"
                    ),
                ]
            ),
        ]
    )
}

private struct MaterializationPageIdentifier:
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

private struct MaterializationPage:
    PageGraphNode
{
    let identifier:
        MaterializationPageIdentifier

    let slug:
        PathSegment?

    let title:
        String

    let visibility:
        Set<BuildEnvironment>

    let children:
        [MaterializationPage]

    init(
        identifier:
            MaterializationPageIdentifier,
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
            [MaterializationPage] = []
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

private func materializationSegment(
    _ value:
        String
) -> PathSegment
{
    PathSegment(
        value,
        .directory
    )
}

private enum StaticMaterializationFlowFailure:
    Error
{
    case missingHome
    case missingContact
    case missingAgreement
}
