import Constructors
import Path
import Primitives
import TestFlows

@main
enum ConstructorsTestFlowMain {
    static func main() async {
        await TestFlowCLI.run(
            suite:
                ConstructorsFlowSuite.self
        )
    }
}

enum ConstructorsFlowSuite:
    TestFlowRegistry
{
    static let title =
        "Constructors semantic flows"

    static let flows:
        [TestFlow] =
    [
        logicalRouteResolution,
        duplicateRouteResolution,
        semanticReferenceResolution,
        siteProjection,
        resolutionProjectionCompaction,
        siteSemantics,
        renderContextReferenceLowering,
        renderResultModel,
        renderOrchestration,
        staticDocumentMaterialization,
        staticDependencyPackaging,
        staticDocumentDependencyIntegration,
        staticTerminalSerialization,
        staticFileWriter,
        staticEndToEndMaterialization,
    ]

    static let logicalRouteResolution =
        TestFlow(
            "logical-route-resolution",
            title:
                "PageGraph resolves logical SiteRoute identity independently of filesystem output",
            tags: [
                "constructors",
                "route",
                "resolution",
                "semantic",
            ]
        ) {
            Step(
                "resolve root and nested logical routes"
            ) {
                let graph =
                    PageGraph(
                        roots: [
                            FixturePage(
                                identifier:
                                    "home",
                                slug:
                                    nil,
                                title:
                                    "Home",
                                children: [
                                    FixturePage(
                                        identifier:
                                            "problems",
                                        slug:
                                            segment(
                                                "problemen"
                                            ),
                                        title:
                                            "Problemen",
                                        children: [
                                            FixturePage(
                                                identifier:
                                                    "behaviour",
                                                slug:
                                                    segment(
                                                        "gedrag"
                                                    ),
                                                title:
                                                    "Gedrag"
                                            ),
                                        ]
                                    ),
                                ]
                            ),
                        ]
                    )

                let resolved =
                    try graph
                        .resolve()
                            .pages

                try Expect.equal(
                    resolved
                        .map {
                            $0
                                .route
                                .siteRoute
                                .href
                        },
                    [
                        "/",
                        "/problemen/",
                        "/problemen/gedrag/",
                    ],
                    "routes.href"
                )

                try Expect.equal(
                    resolved[
                        2
                    ]
                    .route
                    .siteRoute
                    .segments
                    .map(
                        \.rawValue
                    ),
                    [
                        "problemen",
                        "gedrag",
                    ],
                    "routes.semantic-segments"
                )
            }

            Step(
                "page identity remains separate from route identity"
            ) {
                let graph =
                    PageGraph(
                        roots: [
                            FixturePage(
                                identifier:
                                    "home",
                                slug:
                                    nil,
                                title:
                                    "Home"
                            ),
                        ]
                    )

                guard
                    let resolved =
                        try graph
                            .resolve()
                            .pages
                            .first
                else {
                    throw
                        ConstructorsFlowFailure
                            .missingResolvedPage
                }

                try Expect.equal(
                    resolved
                        .identifier
                        .rawValue,
                    "home",
                    "routes.page-identity"
                )

                try Expect.equal(
                    resolved
                        .route
                        .siteRoute,
                    .root,
                    "routes.root-identity"
                )
            }
        }

    static let duplicateRouteResolution =
        TestFlow(
            "duplicate-route-resolution",
            title:
                "Duplicate route detection compares SiteRoute identity rather than serialized href text",
            tags: [
                "constructors",
                "route",
                "identity",
                "conflict",
            ]
        ) {
            Step(
                "reject two pages resolving to the same logical root"
            ) {
                let graph =
                    PageGraph(
                        roots: [
                            FixturePage(
                                identifier:
                                    "first",
                                slug:
                                    nil,
                                title:
                                    "First"
                            ),

                            FixturePage(
                                identifier:
                                    "second",
                                slug:
                                    nil,
                                title:
                                    "Second"
                            ),
                        ]
                    )

                do {
                    _ =
                        try graph
                            .resolve()
                            .pages

                    throw
                        ConstructorsFlowFailure
                            .expectedDuplicateRoute
                } catch
                    let error
                        as PageGraphError
                {
                    try Expect.equal(
                        error,
                        .duplicateRoute(
                            .root
                        ),
                        "routes.duplicate-semantic-identity"
                    )
                }
            }

            Step(
                "reject duplicate nested logical route"
            ) {
                let graph =
                    PageGraph(
                        roots: [
                            FixturePage(
                                identifier:
                                    "root",
                                slug:
                                    nil,
                                title:
                                    "Root",
                                children: [
                                    FixturePage(
                                        identifier:
                                            "first",
                                        slug:
                                            segment(
                                                "same"
                                            ),
                                        title:
                                            "First"
                                    ),

                                    FixturePage(
                                        identifier:
                                            "second",
                                        slug:
                                            segment(
                                                "same"
                                            ),
                                        title:
                                            "Second"
                                    ),
                                ]
                            ),
                        ]
                    )

                do {
                    _ =
                        try graph
                            .resolve()
                            .pages

                    throw
                        ConstructorsFlowFailure
                            .expectedDuplicateRoute
                } catch
                    let error
                        as PageGraphError
                {
                    guard
                        case .duplicateRoute(
                            let route
                        ) =
                            error
                    else {
                        throw
                            ConstructorsFlowFailure
                                .unexpectedPageGraphError
                    }

                    try Expect.equal(
                        route.href,
                        "/same/",
                        "routes.duplicate-nested-href"
                    )

                    try Expect.equal(
                        route
                            .segments
                            .map(
                                \.rawValue
                            ),
                        [
                            "same",
                        ],
                        "routes.duplicate-nested-segments"
                    )
                }
            }
        }

    static let semanticReferenceResolution =
        TestFlow(
            "semantic-reference-resolution",
            title:
                "Site references retain source, destination, and logical route identity through resolution",
            tags: [
                "constructors",
                "reference",
                "resolution",
                "semantic",
            ]
        ) {
            Step(
                "resolve destination identity without producing href text"
            ) {
                let graph =
                    PageGraph(
                        roots: [
                            FixturePage(
                                identifier:
                                    "home",
                                slug:
                                    nil,
                                title:
                                    "Home",
                                children: [
                                    FixturePage(
                                        identifier:
                                            "contact",
                                        slug:
                                            segment(
                                                "contact"
                                            ),
                                        title:
                                            "Contact"
                                    ),

                                    FixturePage(
                                        identifier:
                                            "problems",
                                        slug:
                                            segment(
                                                "problemen"
                                            ),
                                        title:
                                            "Problemen",
                                        children: [
                                            FixturePage(
                                                identifier:
                                                    "behaviour",
                                                slug:
                                                    segment(
                                                        "gedrag"
                                                    ),
                                                title:
                                                    "Gedrag"
                                            ),
                                        ]
                                    ),
                                ]
                            ),
                        ]
                    )

                let reference =
                    SiteReference<
                        FixturePageIdentifier
                    >
                    .to(
                        "contact"
                    )

                let resolved =
                    try graph
                        .resolve()
                        .resolve(
                            reference,
                            from:
                                "home"
                        )

                try Expect.equal(
                    resolved
                        .source
                        .rawValue,
                    "home",
                    "reference.source"
                )

                try Expect.equal(
                    resolved
                        .destination
                        .rawValue,
                    "contact",
                    "reference.destination"
                )

                try Expect.equal(
                    resolved.sourceRoute,
                    .root,
                    "reference.source-route"
                )

                try Expect.equal(
                    resolved
                        .destinationRoute
                        .segments
                        .map(
                            \.rawValue
                        ),
                    [
                        "contact",
                    ],
                    "reference.destination-route"
                )

                try Expect.equal(
                    resolved.style,
                    .automatic,
                    "reference.style"
                )
            }

            Step(
                "retain nested destination route structurally"
            ) {
                let graph =
                    PageGraph(
                        roots: [
                            FixturePage(
                                identifier:
                                    "home",
                                slug:
                                    nil,
                                title:
                                    "Home",
                                children: [
                                    FixturePage(
                                        identifier:
                                            "problems",
                                        slug:
                                            segment(
                                                "problemen"
                                            ),
                                        title:
                                            "Problemen",
                                        children: [
                                            FixturePage(
                                                identifier:
                                                    "behaviour",
                                                slug:
                                                    segment(
                                                        "gedrag"
                                                    ),
                                                title:
                                                    "Gedrag"
                                            ),
                                        ]
                                    ),
                                ]
                            ),
                        ]
                    )

                let resolved =
                    try graph
                        .resolve()
                        .resolve(
                            .to(
                                "behaviour"
                            ),
                            from:
                                "home"
                        )

                try Expect.equal(
                    resolved
                        .destinationRoute
                        .segments
                        .map(
                            \.rawValue
                        ),
                    [
                        "problemen",
                        "gedrag",
                    ],
                    "reference.nested-route"
                )
            }

            Step(
                "preserve explicit reference style without lowering"
            ) {
                let graph =
                    PageGraph(
                        roots: [
                            FixturePage(
                                identifier:
                                    "home",
                                slug:
                                    nil,
                                title:
                                    "Home",
                                children: [
                                    FixturePage(
                                        identifier:
                                            "contact",
                                        slug:
                                            segment(
                                                "contact"
                                            ),
                                        title:
                                            "Contact"
                                    ),
                                ]
                            ),
                        ]
                    )

                let resolved =
                    try graph
                        .resolve()
                        .resolve(
                            .to(
                                "contact",
                                style:
                                    .absolute
                            ),
                            from:
                                "home"
                        )

                try Expect.equal(
                    resolved.style,
                    .absolute,
                    "reference.absolute-style"
                )

                try Expect.equal(
                    resolved
                        .destinationRoute
                        .segments
                        .map(
                            \.rawValue
                        ),
                    [
                        "contact",
                    ],
                    "reference.absolute-route-still-semantic"
                )
            }

            Step(
                "reject unresolved destination identity"
            ) {
                let graph =
                    PageGraph(
                        roots: [
                            FixturePage(
                                identifier:
                                    "home",
                                slug:
                                    nil,
                                title:
                                    "Home"
                            ),
                        ]
                    )

                do {
                    _ =
                        try graph
                            .resolve()
                            .resolve(
                                .to(
                                    "missing"
                                ),
                                from:
                                    "home"
                            )

                    throw
                        ConstructorsFlowFailure
                            .expectedReferenceResolutionFailure
                } catch
                    let error
                        as SiteReferenceResolutionError
                {
                    try Expect.equal(
                        error,
                        .destinationNotFound(
                            "missing"
                        ),
                        "reference.missing-destination"
                    )
                }
            }

            Step(
                "reject unresolved source identity"
            ) {
                let graph =
                    PageGraph(
                        roots: [
                            FixturePage(
                                identifier:
                                    "contact",
                                slug:
                                    segment(
                                        "contact"
                                    ),
                                title:
                                    "Contact"
                            ),
                        ]
                    )

                do {
                    _ =
                        try graph
                            .resolve()
                            .resolve(
                                .to(
                                    "contact"
                                ),
                                from:
                                    "missing-source"
                            )

                    throw
                        ConstructorsFlowFailure
                            .expectedReferenceResolutionFailure
                } catch
                    let error
                        as SiteReferenceResolutionError
                {
                    try Expect.equal(
                        error,
                        .sourceNotFound(
                            "missing-source"
                        ),
                        "reference.missing-source"
                    )
                }
            }
        }


    static let siteProjection =
        TestFlow(
            "site-projection",
            title:
                "Projection decides environment-specific semantic existence without rendering or materialization",
            tags: [
                "constructors",
                "projection",
                "environment",
                "semantic",
            ]
        ) {
            Step(
                "project only pages visible in the environment"
            ) {
                let all:
                    Set<BuildEnvironment> =
                        [
                            .local,
                            .test,
                            .public,
                        ]

                let graph =
                    PageGraph(
                        roots: [
                            FixturePage(
                                identifier:
                                    "home",
                                slug:
                                    nil,
                                title:
                                    "Home",
                                visibility:
                                    all,
                                children: [
                                    FixturePage(
                                        identifier:
                                            "local",
                                        slug:
                                            segment(
                                                "local"
                                            ),
                                        title:
                                            "Local",
                                        visibility: [
                                            .local,
                                        ]
                                    ),

                                    FixturePage(
                                        identifier:
                                            "public",
                                        slug:
                                            segment(
                                                "public"
                                            ),
                                        title:
                                            "Public",
                                        visibility: [
                                            .public,
                                        ]
                                    ),
                                ]
                            ),
                        ]
                    )

                let local =
                    try graph
                        .resolve()
                        .project(
                            in:
                                .local
                        )

                let publicProjection =
                    try graph
                        .resolve()
                        .project(
                            in:
                                .public
                        )

                try Expect.equal(
                    local
                        .pages
                        .map {
                            $0
                                .identifier
                                .rawValue
                        },
                    [
                        "home",
                        "local",
                    ],
                    "projection.local-pages"
                )

                try Expect.equal(
                    publicProjection
                        .pages
                        .map {
                            $0
                                .identifier
                                .rawValue
                        },
                    [
                        "home",
                        "public",
                    ],
                    "projection.public-pages"
                )
            }

            Step(
                "excluded ancestor excludes otherwise visible descendant"
            ) {
                let graph =
                    PageGraph(
                        roots: [
                            FixturePage(
                                identifier:
                                    "home",
                                slug:
                                    nil,
                                title:
                                    "Home",
                                visibility: [
                                    .local,
                                    .test,
                                    .public,
                                ],
                                children: [
                                    FixturePage(
                                        identifier:
                                            "local-parent",
                                        slug:
                                            segment(
                                                "local-parent"
                                            ),
                                        title:
                                            "Local parent",
                                        visibility: [
                                            .local,
                                        ],
                                        children: [
                                            FixturePage(
                                                identifier:
                                                    "public-child",
                                                slug:
                                                    segment(
                                                        "public-child"
                                                    ),
                                                title:
                                                    "Public child",
                                                visibility: [
                                                    .local,
                                                    .public,
                                                ]
                                            ),
                                        ]
                                    ),
                                ]
                            ),
                        ]
                    )

                let projection =
                    try graph
                        .resolve()
                        .project(
                            in:
                                .public
                        )

                try Expect.equal(
                    projection
                        .pages
                        .map {
                            $0
                                .identifier
                                .rawValue
                        },
                    [
                        "home",
                    ],
                    "projection.ancestor-gates-descendant"
                )
            }

            Step(
                "preserve resolved route identity through projection"
            ) {
                let graph =
                    PageGraph(
                        roots: [
                            FixturePage(
                                identifier:
                                    "home",
                                slug:
                                    nil,
                                title:
                                    "Home",
                                visibility: [
                                    .public,
                                ],
                                children: [
                                    FixturePage(
                                        identifier:
                                            "problems",
                                        slug:
                                            segment(
                                                "problemen"
                                            ),
                                        title:
                                            "Problemen",
                                        visibility: [
                                            .public,
                                        ],
                                        children: [
                                            FixturePage(
                                                identifier:
                                                    "behaviour",
                                                slug:
                                                    segment(
                                                        "gedrag"
                                                    ),
                                                title:
                                                    "Gedrag",
                                                visibility: [
                                                    .public,
                                                ]
                                            ),
                                        ]
                                    ),
                                ]
                            ),
                        ]
                    )

                let projection =
                    try graph
                        .resolve()
                        .project(
                            in:
                                .public
                        )

                guard
                    let behaviour =
                        projection[
                            "behaviour"
                        ]
                else {
                    throw
                        ConstructorsFlowFailure
                            .missingProjectedPage
                }

                try Expect.equal(
                    behaviour
                        .siteRoute
                        .segments
                        .map(
                            \.rawValue
                        ),
                    [
                        "problemen",
                        "gedrag",
                    ],
                    "projection.route-identity"
                )

                let resolved =
                    try graph
                        .resolve()
                            .pages
                        .first {
                            $0
                                .identifier
                                .rawValue
                                == "behaviour"
                        }

                guard
                    let resolved
                else {
                    throw
                        ConstructorsFlowFailure
                            .missingResolvedPage
                }

                try Expect.equal(
                    behaviour.siteRoute,
                    resolved
                        .route
                        .siteRoute,
                    "projection.route-preserved"
                )
            }

            Step(
                "reference resolution is constrained by projected existence"
            ) {
                let graph =
                    PageGraph(
                        roots: [
                            FixturePage(
                                identifier:
                                    "home",
                                slug:
                                    nil,
                                title:
                                    "Home",
                                visibility: [
                                    .local,
                                    .public,
                                ],
                                children: [
                                    FixturePage(
                                        identifier:
                                            "private",
                                        slug:
                                            segment(
                                                "private"
                                            ),
                                        title:
                                            "Private",
                                        visibility: [
                                            .local,
                                        ]
                                    ),
                                ]
                            ),
                        ]
                    )

                let globalReference =
                    try graph
                        .resolve()
                        .resolve(
                            .to(
                                "private"
                            ),
                            from:
                                "home"
                        )

                try Expect.equal(
                    globalReference
                        .destination
                        .rawValue,
                    "private",
                    "projection.reference-globally-valid"
                )

                let publicProjection =
                    try graph
                        .resolve()
                        .project(
                            in:
                                .public
                        )

                do {
                    _ =
                        try publicProjection
                            .project(
                                try graph
                                    .resolve()
                                    .resolve(
                                        .to(
                                            "private"
                                        ),
                                        from:
                                            "home"
                                    )
                            )

                    throw
                        ConstructorsFlowFailure
                            .expectedProjectionReferenceFailure
                } catch
                    let error
                        as SiteProjectionError
                {
                    try Expect.equal(
                        error,
                        .destinationNotProjected(
                            "private"
                        ),
                        "projection.reference-excluded-destination"
                    )
                }

                let localProjection =
                    try graph
                        .resolve()
                        .project(
                            in:
                                .local
                        )

                let localReference =
                    try localProjection
                        .project(
                            try graph
                                .resolve()
                                .resolve(
                                    .to(
                                        "private"
                                    ),
                                    from:
                                        "home"
                                )
                        )

                try Expect.equal(
                    localReference
                        .destinationRoute
                        .segments
                        .map(
                            \.rawValue
                        ),
                    [
                        "private",
                    ],
                    "projection.reference-local-route"
                )
            }

            Step(
                "hidden source cannot originate a projected reference"
            ) {
                let graph =
                    PageGraph(
                        roots: [
                            FixturePage(
                                identifier:
                                    "hidden-source",
                                slug:
                                    nil,
                                title:
                                    "Hidden source",
                                visibility: [
                                    .local,
                                ],
                                children: [
                                    FixturePage(
                                        identifier:
                                            "target",
                                        slug:
                                            segment(
                                                "target"
                                            ),
                                        title:
                                            "Target",
                                        visibility: [
                                            .local,
                                            .public,
                                        ]
                                    ),
                                ]
                            ),
                        ]
                    )

                let projection =
                    try graph
                        .resolve()
                        .project(
                            in:
                                .public
                        )

                do {
                    _ =
                        try projection
                            .project(
                                try graph
                                    .resolve()
                                    .resolve(
                                        .to(
                                            "target"
                                        ),
                                        from:
                                            "hidden-source"
                                    )
                            )

                    throw
                        ConstructorsFlowFailure
                            .expectedProjectionReferenceFailure
                } catch
                    let error
                        as SiteProjectionError
                {
                    try Expect.equal(
                        error,
                        .sourceNotProjected(
                            "hidden-source"
                        ),
                        "projection.reference-excluded-source"
                    )
                }
            }
        }

}

private struct FixturePageIdentifier:
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

private struct FixturePage:
    PageGraphNode
{
    let identifier:
        FixturePageIdentifier

    let slug:
        PathSegment?

    let title:
        String

    let visibility:
        Set<BuildEnvironment>

    let children:
        [FixturePage]

    init(
        identifier:
            FixturePageIdentifier,
        slug:
            PathSegment?,
        title:
            String,
        visibility:
            Set<BuildEnvironment> = [],
        children:
            [FixturePage] = []
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

private func segment(
    _ value:
        String
) -> PathSegment {
    PathSegment(
        value,
        .directory
    )
}

private enum ConstructorsFlowFailure:
    Error
{
    case missingResolvedPage
    case missingProjectedPage
    case expectedDuplicateRoute
    case unexpectedPageGraphError
    case expectedReferenceResolutionFailure
    case expectedProjectionReferenceFailure
}
