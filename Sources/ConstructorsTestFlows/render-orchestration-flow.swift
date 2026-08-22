import CSS
import Constructors
import HTML
import JS
import Path
import Primitives
import TestFlows

extension ConstructorsFlowSuite {
    static let renderOrchestration =
        TestFlow(
            "render-orchestration",
            title:
                "Caller-owned typed state drives single-page and whole-site rendering without entering Constructors state",
            tags: [
                "constructors",
                "orchestration",
                "rendering",
                "semantic",
                "ssr",
                "state",
            ]
        ) {
            Step(
                "typed caller state participates in single-page rendering"
            ) {
                let projection =
                    try orchestrationGraph()
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
                    OrchestrationState(
                        scriptIdentifier:
                            "state-script",
                        scriptCode:
                            "window.state = 'authenticated';"
                    )

                let rendered =
                    try context
                        .render(
                            page:
                                "home",
                            state:
                                state
                        ) {
                            page,
                            state,
                            renderContext
                            in

                            try Expect.equal(
                                page
                                    .identifier
                                    .rawValue,
                                "home",
                                "render-orchestration.single-page-projection"
                            )

                            try Expect.equal(
                                renderContext
                                    .projection[
                                        page.identifier
                                    ]?
                                    .siteRoute
                                    .href,
                                "/",
                                "render-orchestration.context-projection"
                            )

                            return
                                orchestrationOutput(
                                    state:
                                        state
                                )
                        }

                try Expect.equal(
                    rendered
                        .identifier
                        .rawValue,
                    "home",
                    "render-orchestration.single-page-identifier"
                )

                try Expect.equal(
                    rendered
                        .scripts
                        .identifiers
                        .map(
                            \.rawValue
                        ),
                    [
                        "state-script",
                    ],
                    "render-orchestration.caller-state-observed"
                )
            }

            Step(
                "RenderContext rejects a page absent from its projection before invoking the renderer"
            ) {
                let projection =
                    try orchestrationGraph()
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

                do {
                    _ =
                        try context
                            .render(
                                page:
                                    "draft",
                                state:
                                    OrchestrationState(
                                        scriptIdentifier:
                                            "unused",
                                        scriptCode:
                                            "window.unused = true;"
                                    )
                            ) {
                                _,
                                _,
                                _
                                in

                                throw
                                    OrchestrationFlowFailure
                                        .rendererShouldNotRun
                            }

                    throw
                        OrchestrationFlowFailure
                            .expectedPageNotProjected
                } catch
                    let error
                        as RenderContextRenderingError
                {
                    try Expect.equal(
                        error,
                        .pageNotProjected(
                            "draft"
                        ),
                        "render-orchestration.page-not-projected"
                    )
                }
            }

            Step(
                "RenderContext establishes dependency-resolution invariants"
            ) {
                let projection =
                    try orchestrationGraph()
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

                do {
                    _ =
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
                                        orchestrationDocument(),
                                    scripts:
                                        JSContributions(
                                            [
                                                JSContribution(
                                                    identifier:
                                                        "conflict",
                                                    script:
                                                        .inline(
                                                            JSSource(
                                                                "window.value = 1;"
                                                            )
                                                        )
                                                ),
                                                JSContribution(
                                                    identifier:
                                                        "conflict",
                                                    script:
                                                        .inline(
                                                            JSSource(
                                                                "window.value = 2;"
                                                            )
                                                        )
                                                ),
                                            ]
                                        )
                                )
                            }

                    throw
                        OrchestrationFlowFailure
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
                            "conflict",
                            "render-orchestration.page-resolution-conflict"
                        )
                    }
                }
            }

            Step(
                "whole-site rendering uses exactly the projected pages and derives stable site dependencies"
            ) {
                let projection =
                    try orchestrationGraph()
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
                    OrchestrationState(
                        scriptIdentifier:
                            "shared-script",
                        scriptCode:
                            "window.shared = true;"
                    )

                let result =
                    try context
                        .renderSite(
                            state:
                                state
                        ) {
                            _,
                            state,
                            _
                            in

                            orchestrationOutput(
                                state:
                                    state
                            )
                        }

                try Expect.equal(
                    result
                        .documents
                        .map {
                            $0.identifier
                                .rawValue
                        },
                    [
                        "home",
                        "contact",
                    ],
                    "render-orchestration.projected-documents-only"
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
                    "render-orchestration.site-style-deduplication"
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
                    "render-orchestration.site-script-deduplication"
                )
            }

            Step(
                "state-free rendering uses the same document boundary"
            ) {
                let projection =
                    try orchestrationGraph()
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

                let rendered =
                    try context
                        .render(
                            page:
                                "contact"
                        ) {
                            _,
                            _
                            in

                            PageRenderOutput(
                                document:
                                    orchestrationDocument()
                            )
                        }

                try Expect.equal(
                    rendered
                        .identifier
                        .rawValue,
                    "contact",
                    "render-orchestration.state-free-page"
                )

                try Expect.equal(
                    rendered
                        .route
                        .href,
                    "/contact/",
                    "render-orchestration.state-free-route"
                )
            }
        }
}

private struct OrchestrationState:
    Sendable
{
    let scriptIdentifier:
        String

    let scriptCode:
        String
}

private func orchestrationOutput(
    state:
        OrchestrationState
) -> PageRenderOutput {
    PageRenderOutput(
        document:
            orchestrationDocument(),
        styles:
            CSSContributions(
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
            ),
        scripts:
            JSContributions(
                [
                    JSContribution(
                        identifier:
                            JSContributionIdentifier(
                                state
                                    .scriptIdentifier
                            ),
                        script:
                            .inline(
                                JSSource(
                                    state
                                        .scriptCode
                                )
                            )
                    ),
                ]
            )
    )
}

private func orchestrationDocument() -> HTMLDocument {
    HTMLDocument(
        attributes:
            .empty,
        head:
            [],
        body:
            []
    )
}

private func orchestrationGraph()
    -> PageGraph<OrchestrationPage>
{
    PageGraph(
        roots: [
            OrchestrationPage(
                identifier:
                    "home",
                slug:
                    nil,
                title:
                    "Home",
                children: [
                    OrchestrationPage(
                        identifier:
                            "contact",
                        slug:
                            orchestrationSegment(
                                "contact"
                            ),
                        title:
                            "Contact"
                    ),
                    OrchestrationPage(
                        identifier:
                            "draft",
                        slug:
                            orchestrationSegment(
                                "draft"
                            ),
                        title:
                            "Draft",
                        visibility: [
                            .local,
                        ]
                    ),
                ]
            ),
        ]
    )
}

private struct OrchestrationPageIdentifier:
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

private struct OrchestrationPage:
    PageGraphNode
{
    let identifier:
        OrchestrationPageIdentifier

    let slug:
        PathSegment?

    let title:
        String

    let visibility:
        Set<BuildEnvironment>

    let children:
        [OrchestrationPage]

    init(
        identifier:
            OrchestrationPageIdentifier,
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
            [OrchestrationPage] = []
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

private func orchestrationSegment(
    _ value:
        String
) -> PathSegment {
    PathSegment(
        value,
        .directory
    )
}

private enum OrchestrationFlowFailure:
    Error
{
    case expectedPageNotProjected
    case expectedDependencyConflict
    case rendererShouldNotRun
}
