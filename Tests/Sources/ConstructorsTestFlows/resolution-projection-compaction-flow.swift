import Constructors
import Path
import Primitives
import TestFlows

extension ConstructorsFlowSuite {
    static let resolutionProjectionCompaction =
        TestFlow(
            "resolution-projection-compaction",
            title:
                "Resolution produces reusable structural graph state and projection only strengthens that state",
            tags: [
                "constructors",
                "graph",
                "navigation",
                "projection",
                "reference",
                "resolution",
                "semantic",
            ]
        ) {
            Step(
                "resolved graph carries collection-level route and identity invariants"
            ) {
                let resolved =
                    try compactionGraph()
                        .resolve()

                try Expect.equal(
                    resolved
                        .pages
                        .map {
                            $0
                                .identifier
                                .rawValue
                        },
                    [
                        "home",
                        "zeta",
                        "hidden",
                        "hidden-child",
                        "alpha",
                    ],
                    "compaction.resolved-page-order"
                )

                guard
                    let alpha =
                        resolved[
                            "alpha"
                        ]
                else {
                    throw
                        ResolutionProjectionCompactionFailure
                            .missingPage(
                                "alpha"
                            )
                }

                try Expect.equal(
                    alpha
                        .route
                        .siteRoute
                        .href,
                    "/alpha/",
                    "compaction.resolved-graph-lookup"
                )
            }

            Step(
                "one resolved graph feeds both semantic reference resolution and projection"
            ) {
                let resolved =
                    try compactionGraph()
                        .resolve()

                let reference =
                    try resolved
                        .resolve(
                            .to(
                                "zeta"
                            ),
                            from:
                                "home"
                        )

                let projection =
                    resolved
                        .project(
                            in:
                                .public
                        )

                let projected =
                    try projection
                        .project(
                            reference
                        )

                try Expect.equal(
                    projected.resolved,
                    reference,
                    "compaction.projected-reference-exact-provenance"
                )

                try Expect.equal(
                    projected
                        .destinationRoute,
                    resolved[
                        "zeta"
                    ]?
                    .route
                    .siteRoute,
                    "compaction.reference-route-remains-resolved-identity"
                )
            }

            Step(
                "projection rejects a globally valid reference whose destination does not exist here"
            ) {
                let resolved =
                    try compactionGraph()
                        .resolve()

                let reference =
                    try resolved
                        .resolve(
                            .to(
                                "hidden"
                            ),
                            from:
                                "home"
                        )

                let projection =
                    resolved
                        .project(
                            in:
                                .public
                        )

                do {
                    _ =
                        try projection
                            .project(
                                reference
                            )

                    throw
                        ResolutionProjectionCompactionFailure
                            .expectedProjectionFailure
                } catch
                    let error
                        as SiteProjectionError
                {
                    try Expect.equal(
                        error,
                        .destinationNotProjected(
                            "hidden"
                        ),
                        "compaction.excluded-reference-destination"
                    )
                }
            }

            Step(
                "navigation derives only from projected pages and preserves resolved routes"
            ) {
                let resolved =
                    try compactionGraph()
                        .resolve()

                let projection =
                    resolved
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
                        "zeta",
                        "alpha",
                    ],
                    "compaction.projected-pages"
                )

                try Expect.equal(
                    projection[
                        "hidden-child"
                    ] == nil,
                    true,
                    "compaction.excluded-ancestor-excludes-descendant"
                )

                let insertion =
                    projection
                        .navigation(
                            sortOrder:
                                .insertion
                        )

                guard
                    let insertionRoot =
                        insertion
                            .roots
                            .first
                else {
                    throw
                        ResolutionProjectionCompactionFailure
                            .missingNavigationRoot
                }

                try Expect.equal(
                    insertionRoot.label,
                    "Home",
                    "compaction.navigation-root-label"
                )

                try Expect.equal(
                    insertionRoot.path,
                    "/",
                    "compaction.navigation-root-resolved-route"
                )

                try Expect.equal(
                    insertionRoot
                        .children
                        .map(
                            \.label
                        ),
                    [
                        "Zeta",
                        "Alpha",
                    ],
                    "compaction.navigation-insertion-order"
                )

                try Expect.equal(
                    insertionRoot
                        .children
                        .map(
                            \.path
                        ),
                    [
                        projection[
                            "zeta"
                        ]?
                        .siteRoute
                        .href,
                        projection[
                            "alpha"
                        ]?
                        .siteRoute
                        .href,
                    ],
                    "compaction.navigation-preserves-resolved-route-identity"
                )

                let alphabetical =
                    projection
                        .navigation(
                            sortOrder:
                                .alphabetical
                        )

                try Expect.equal(
                    alphabetical
                        .roots
                        .first?
                        .children
                        .map(
                            \.label
                        ),
                    [
                        "Alpha",
                        "Zeta",
                    ],
                    "compaction.navigation-alphabetical-order"
                )
            }
        }
}

private struct CompactionPageIdentifier:
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

private struct CompactionPage:
    PageGraphNode
{
    let identifier:
        CompactionPageIdentifier

    let slug:
        PathSegment?

    let title:
        String

    let visibility:
        Set<BuildEnvironment>

    let children:
        [CompactionPage]

    init(
        identifier:
            CompactionPageIdentifier,
        slug:
            PathSegment?,
        title:
            String,
        visibility:
            Set<BuildEnvironment>,
        children:
            [CompactionPage] = []
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

private func compactionGraph()
    -> PageGraph<
        CompactionPage
    >
{
    PageGraph(
        roots: [
            CompactionPage(
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
                    CompactionPage(
                        identifier:
                            "zeta",
                        slug:
                            compactionSegment(
                                "zeta"
                            ),
                        title:
                            "Zeta",
                        visibility: [
                            .local,
                            .public,
                        ]
                    ),
                    CompactionPage(
                        identifier:
                            "hidden",
                        slug:
                            compactionSegment(
                                "hidden"
                            ),
                        title:
                            "Hidden",
                        visibility: [
                            .local,
                        ],
                        children: [
                            CompactionPage(
                                identifier:
                                    "hidden-child",
                                slug:
                                    compactionSegment(
                                        "child"
                                    ),
                                title:
                                    "Hidden Child",
                                visibility: [
                                    .local,
                                    .public,
                                ]
                            ),
                        ]
                    ),
                    CompactionPage(
                        identifier:
                            "alpha",
                        slug:
                            compactionSegment(
                                "alpha"
                            ),
                        title:
                            "Alpha",
                        visibility: [
                            .local,
                            .public,
                        ]
                    ),
                ]
            ),
        ]
    )
}

private func compactionSegment(
    _ value:
        String
) -> PathSegment {
    PathSegment(
        value,
        .directory
    )
}

private enum ResolutionProjectionCompactionFailure:
    Error
{
    case missingPage(
        String
    )

    case expectedProjectionFailure
    case missingNavigationRoot
}
