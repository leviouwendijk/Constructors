import Constructors
import Foundation
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

                let projection =
                    try graph
                        .project(
                            in:
                                .public
                        )

                let projected =
                    try projection
                        .resolve(
                            .to(
                                "contact"
                            ),
                            from:
                                "home"
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
                let projection =
                    try renderFixtureGraph()
                        .project(
                            in:
                                .public
                        )

                let projected =
                    try projection
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
                let projection =
                    try renderFixtureGraph()
                        .project(
                            in:
                                .public
                        )

                let projected =
                    try projection
                        .resolve(
                            .to(
                                "contact",
                                style:
                                    .absolute
                            ),
                            from:
                                "home"
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
