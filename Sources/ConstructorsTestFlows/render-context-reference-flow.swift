import CSS
import Constructors
import Foundation
import HTML
import JS
import Path
import Primitives
import TestFlows

extension ConstructorsFlowSuite {
    static let renderContextReferenceLowering =
        TestFlow(
            "render-context-reference-lowering",
            title:
                "RenderContext lowers projection-proven semantic references without materialization",
            tags: [
                "constructors",
                "projection",
                "reference",
                "rendering",
                "semantic",
            ]
        ) {
            Step(
                "projection strengthens resolved relationship before rendering"
            ) {
                let graph =
                    renderFixtureGraph()

                let resolvedGraph =
                    try graph
                        .resolve()

                let resolvedReference =
                    try resolvedGraph
                        .resolve(
                            .to(
                                "contact"
                            ),
                            from:
                                "home"
                        )

                let projection =
                    resolvedGraph
                        .project(
                            in:
                                .public
                        )

                let projected =
                    try projection
                        .project(
                            resolvedReference
                        )

                try Expect.equal(
                    projected.resolved,
                    resolvedReference,
                    "render-context.exact-resolved-reference-provenance"
                )

                try Expect.equal(
                    projected
                        .resolved
                        .destination
                        .rawValue,
                    "contact",
                    "render-context.projected-resolved-destination"
                )

                try Expect.equal(
                    projected
                        .destinationRoute
                        .href,
                    "/contact/",
                    "render-context.projected-route"
                )

                let context =
                    RenderContext(
                        projection:
                            projection
                    )

                try Expect.equal(
                    context
                        .projection
                        .environment,
                    .public,
                    "render-context.projection"
                )

                let rendered =
                    try context
                        .render(
                            projected
                        )

                try Expect.equal(
                    rendered.href,
                    "/contact/",
                    "render-context.automatic-href"
                )

                try Expect.equal(
                    rendered.projected,
                    projected,
                    "render-context.semantic-provenance"
                )
            }

            Step(
                "explicit local relative style lowers logical route without root slash"
            ) {
                let resolvedGraph =
                    try renderFixtureGraph()
                        .resolve()

                let projection =
                    resolvedGraph
                        .project(
                            in:
                                .public
                        )

                let resolvedReference =
                    try resolvedGraph
                        .resolve(
                            .to(
                                "contact",
                                style:
                                    .local(
                                        .relative
                                    )
                            ),
                            from:
                                "home"
                        )

                let projected =
                    try projection
                        .project(
                            resolvedReference
                        )

                let rendered =
                    try RenderContext(
                        projection:
                            projection
                    )
                    .render(
                        projected
                    )

                try Expect.equal(
                    rendered.href,
                    "contact/",
                    "render-context.relative-href"
                )
            }

            Step(
                "absolute style requires explicit site-level rendering base URL"
            ) {
                let resolvedGraph =
                    try renderFixtureGraph()
                        .resolve()

                let projection =
                    resolvedGraph
                        .project(
                            in:
                                .public
                        )

                let resolvedReference =
                    try resolvedGraph
                        .resolve(
                            .to(
                                "contact",
                                style:
                                    .absolute
                            ),
                            from:
                                "home"
                        )

                let projected =
                    try projection
                        .project(
                            resolvedReference
                        )

                do {
                    _ =
                        try RenderContext(
                            projection:
                                projection
                        )
                        .render(
                            projected
                        )

                    throw
                        RenderContextFlowFailure
                            .expectedAbsolutePolicyFailure
                } catch
                    let error
                        as SiteRenderingPolicyError
                {
                    try Expect.equal(
                        error,
                        .absoluteReferenceRequiresBaseURL,
                        "render-context.absolute-policy-required"
                    )
                }

                guard
                    let baseURL =
                        URL(
                            string:
                                "https://example.test"
                        )
                else {
                    throw
                        RenderContextFlowFailure
                            .invalidFixtureURL
                }

                let rendered =
                    try RenderContext(
                        projection:
                            projection,
                        policy:
                            SiteRenderingPolicy(
                                absoluteBaseURL:
                                    baseURL
                            )
                    )
                    .render(
                        projected
                    )

                try Expect.equal(
                    rendered.href,
                    "https://example.test/contact/",
                    "render-context.absolute-href"
                )
            }
        }
}

extension ConstructorsFlowSuite {
    static let renderResultModel =
        TestFlow(
            "render-result-model",
            title:
                "Rendering retains projected documents and resolved dependency identity without materialization",
            tags: [
                "constructors",
                "dependencies",
                "document",
                "rendering",
                "semantic",
            ]
        ) {
            Step(
                "rendered document retains projected semantic and domain representations"
            ) {
                let projection =
                    try renderFixtureGraph()
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
                        RenderResultFlowFailure
                            .missingFixturePage(
                                "home"
                            )
                }

                let dependencies =
                    try renderSharedDependencies()

                let rendered =
                    RenderedDocument(
                        projectedPage:
                            home,
                        document:
                            renderFixtureDocument(),
                        dependencies:
                            dependencies
                    )

                try Expect.equal(
                    rendered
                        .identifier
                        .rawValue,
                    "home",
                    "render-result.document-identifier"
                )

                try Expect.equal(
                    rendered
                        .route
                        .href,
                    "/",
                    "render-result.document-route"
                )

                try Expect.equal(
                    rendered
                        .styles
                        .identifiers
                        .map(
                            \.rawValue
                        ),
                    [
                        "shared-style",
                    ],
                    "render-result.document-style-identity"
                )

                try Expect.equal(
                    rendered
                        .scripts
                        .identifiers
                        .map(
                            \.rawValue
                        ),
                    [
                        "shared-script",
                    ],
                    "render-result.document-script-identity"
                )

                try Expect.equal(
                    renderedResourceRoute(
                        rendered
                    )
                    .href,
                    "/",
                    "render-result.rendered-resource-conformance"
                )
            }

            Step(
                "site result derives one stable dependency set across documents"
            ) {
                let projection =
                    try renderFixtureGraph()
                        .resolve()
                        .project(
                            in:
                                .public
                        )

                guard
                    let home =
                        projection[
                            "home"
                        ],
                    let contact =
                        projection[
                            "contact"
                        ]
                else {
                    throw
                        RenderResultFlowFailure
                            .missingFixturePage(
                                "home/contact"
                            )
                }

                let dependencies =
                    try renderSharedDependencies()

                let result =
                    try SiteRenderResult(
                        projection:
                            projection,
                        documents: [
                            RenderedDocument(
                                projectedPage:
                                    home,
                                document:
                                    renderFixtureDocument(),
                                dependencies:
                                    dependencies
                            ),
                            RenderedDocument(
                                projectedPage:
                                    contact,
                                document:
                                    renderFixtureDocument(),
                                dependencies:
                                    dependencies
                            ),
                        ]
                    )

                try Expect.equal(
                    result
                        .documents
                        .count,
                    2,
                    "render-result.document-count"
                )

                try Expect.equal(
                    result
                        .dependencies
                        .styles
                        .identifiers
                        .map(
                            \.rawValue
                        ),
                    [
                        "shared-style",
                    ],
                    "render-result.site-style-deduplication"
                )

                try Expect.equal(
                    result
                        .dependencies
                        .scripts
                        .identifiers
                        .map(
                            \.rawValue
                        ),
                    [
                        "shared-script",
                    ],
                    "render-result.site-script-deduplication"
                )

                try Expect.equal(
                    result
                        .projection[
                            "contact"
                        ]?
                        .siteRoute
                        .href,
                    "/contact/",
                    "render-result.projection-retained"
                )
            }

            Step(
                "site result rejects document route drift from its projection"
            ) {
                let projection =
                    try renderFixtureGraph()
                        .resolve()
                        .project(
                            in:
                                .public
                        )

                let driftedGraph =
                    PageGraph(
                        roots: [
                            RenderFixturePage(
                                identifier:
                                    "home",
                                slug:
                                    renderSegment(
                                        "drifted"
                                    ),
                                title:
                                    "Home"
                            ),
                        ]
                    )

                let driftedProjection =
                    try driftedGraph
                        .resolve()
                        .project(
                            in:
                                .public
                        )

                guard
                    let driftedHome =
                        driftedProjection[
                            "home"
                        ]
                else {
                    throw
                        RenderResultFlowFailure
                            .missingFixturePage(
                                "drifted-home"
                            )
                }

                let rendered =
                    RenderedDocument(
                        projectedPage:
                            driftedHome,
                        document:
                            renderFixtureDocument(),
                        dependencies:
                            try renderSharedDependencies()
                    )

                do {
                    _ =
                        try SiteRenderResult(
                            projection:
                                projection,
                            documents: [
                                rendered,
                            ]
                        )

                    throw
                        RenderResultFlowFailure
                            .expectedRouteMismatch
                } catch
                    let error
                        as SiteRenderResultError
                {
                    switch error {
                    case .documentRouteMismatch(
                        let identifier,
                        let projected,
                        let rendered
                    ):
                        try Expect.equal(
                            identifier,
                            "home",
                            "render-result.route-mismatch-identifier"
                        )

                        try Expect.equal(
                            projected.href,
                            "/",
                            "render-result.route-mismatch-projected"
                        )

                        try Expect.equal(
                            rendered.href,
                            "/drifted/",
                            "render-result.route-mismatch-rendered"
                        )

                    case .documentNotProjected:
                        throw
                            RenderResultFlowFailure
                                .unexpectedRenderResultError
                    }
                }
            }

            Step(
                "site-wide dependency conflicts remain resolution failures"
            ) {
                let projection =
                    try renderFixtureGraph()
                        .resolve()
                        .project(
                            in:
                                .public
                        )

                guard
                    let home =
                        projection[
                            "home"
                        ],
                    let contact =
                        projection[
                            "contact"
                        ]
                else {
                    throw
                        RenderResultFlowFailure
                            .missingFixturePage(
                                "home/contact"
                            )
                }

                let firstDependencies =
                    try renderSharedDependencies(
                        scriptCode:
                            "window.shared = 1;"
                    )

                let conflictingDependencies =
                    try renderSharedDependencies(
                        scriptCode:
                            "window.shared = 2;"
                    )

                do {
                    _ =
                        try SiteRenderResult(
                            projection:
                                projection,
                            documents: [
                                RenderedDocument(
                                    projectedPage:
                                        home,
                                    document:
                                        renderFixtureDocument(),
                                    dependencies:
                                        firstDependencies
                                ),
                                RenderedDocument(
                                    projectedPage:
                                        contact,
                                    document:
                                        renderFixtureDocument(),
                                    dependencies:
                                        conflictingDependencies
                                ),
                            ]
                        )

                    throw
                        RenderResultFlowFailure
                            .expectedDependencyConflict
                } catch
                    let error
                        as JSContributionResolutionError
                {
                    switch error {
                    case .conflicting(
                        let identifier
                    ):
                        try Expect.equal(
                            identifier
                                .rawValue,
                            "shared-script",
                            "render-result.site-dependency-conflict"
                        )
                    }
                }
            }
        }
}

private func renderSharedDependencies(
    scriptCode:
        String = "window.shared = true;"
) throws -> RenderDependencies {
    let styles =
        try CSSContributions(
            [
                CSSContribution(
                    identifier:
                        "shared-style",
                    content:
                        CSSContributionSet(
                            units:
                                []
                        )
                ),
            ]
        )
        .resolve()

    let scripts =
        try JSContributions(
            [
                JSContribution(
                    identifier:
                        "shared-script",
                    script:
                        .inline(
                            JSSource(
                                scriptCode
                            )
                        )
                ),
            ]
        )
        .resolve()

    return
        RenderDependencies(
            styles:
                styles,
            scripts:
                scripts
        )
}

private func renderFixtureDocument() -> HTMLDocument {
    HTMLDocument(
        attributes:
            .empty,
        head:
            [],
        body:
            []
    )
}

private func renderedResourceRoute<
    Resource:
        RenderedResource
>(
    _ resource:
        Resource
) -> SiteRoute {
    resource
        .route
}

private enum RenderResultFlowFailure:
    Error
{
    case missingFixturePage(
        String
    )

    case expectedRouteMismatch

    case expectedDependencyConflict

    case unexpectedRenderResultError
}

private func renderFixtureGraph() -> PageGraph<RenderFixturePage> {
    PageGraph(
        roots: [
            RenderFixturePage(
                identifier:
                    "home",
                slug:
                    nil,
                title:
                    "Home",
                children: [
                    RenderFixturePage(
                        identifier:
                            "contact",
                        slug:
                            renderSegment(
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

private struct RenderFixturePageIdentifier:
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

private struct RenderFixturePage:
    PageGraphNode
{
    let identifier:
        RenderFixturePageIdentifier

    let slug:
        PathSegment?

    let title:
        String

    let visibility:
        Set<BuildEnvironment>

    let children:
        [RenderFixturePage]

    init(
        identifier:
            RenderFixturePageIdentifier,
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
            [RenderFixturePage] = []
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

private func renderSegment(
    _ value:
        String
) -> PathSegment {
    PathSegment(
        value,
        .directory
    )
}

private enum RenderContextFlowFailure:
    Error
{
    case expectedAbsolutePolicyFailure
    case invalidFixtureURL
}
