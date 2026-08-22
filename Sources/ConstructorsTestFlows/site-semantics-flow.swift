import Constructors
import Path
import Primitives
import TestFlows

extension ConstructorsFlowSuite {
    static let siteSemantics =
        TestFlow(
            "site-semantics",
            title:
                "DeclaredSite carries semantic relationships through Resolution and Projection before RenderContext lowers them",
            tags: [
                "constructors",
                "declaration",
                "projection",
                "reference",
                "rendering",
                "resolution",
                "semantic",
                "site",
            ]
        ) {
            Step(
                "site declaration resolves one page graph and all declared relationships against that exact graph"
            ) {
                let resolved =
                    try siteSemanticsDeclaration()
                        .resolve()

                try Expect.equal(
                    resolved
                        .pages
                        .pages
                        .map {
                            $0
                                .identifier
                                .rawValue
                        },
                    [
                        "home",
                        "contact",
                        "about",
                    ],
                    "site-semantics.resolved-pages"
                )

                try Expect.equal(
                    resolved
                        .references
                        .count,
                    2,
                    "site-semantics.resolved-reference-count"
                )

                let contact =
                    resolved
                        .references[
                            0
                        ]

                try Expect.equal(
                    contact
                        .source
                        .rawValue,
                    "home",
                    "site-semantics.reference-source"
                )

                try Expect.equal(
                    contact
                        .destination
                        .rawValue,
                    "contact",
                    "site-semantics.reference-destination"
                )

                try Expect.equal(
                    contact
                        .sourceRoute,
                    .root,
                    "site-semantics.reference-source-route"
                )

                try Expect.equal(
                    contact
                        .destinationRoute
                        .href,
                    "/contact/",
                    "site-semantics.reference-destination-route"
                )

                try Expect.equal(
                    contact
                        .style,
                    .automatic,
                    "site-semantics.reference-style"
                )
            }

            Step(
                "site resolution rejects a declared relationship whose destination does not exist"
            ) {
                let declaration =
                    DeclaredSite(
                        pages:
                            siteSemanticsGraph(),
                        references: [
                            siteSemanticsReference(
                                from:
                                    "home",
                                to:
                                    "missing"
                            ),
                        ]
                    )

                do {
                    _ =
                        try declaration
                            .resolve()

                    throw
                        SiteSemanticsFlowFailure
                            .expectedResolutionFailure
                } catch
                    let error
                        as SiteReferenceResolutionError
                {
                    try Expect.equal(
                        error,
                        .destinationNotFound(
                            "missing"
                        ),
                        "site-semantics.missing-destination"
                    )
                }
            }

            Step(
                "site resolution rejects a declared relationship whose source does not exist"
            ) {
                let declaration =
                    DeclaredSite(
                        pages:
                            siteSemanticsGraph(),
                        references: [
                            siteSemanticsReference(
                                from:
                                    "missing",
                                to:
                                    "contact"
                            ),
                        ]
                    )

                do {
                    _ =
                        try declaration
                            .resolve()

                    throw
                        SiteSemanticsFlowFailure
                            .expectedResolutionFailure
                } catch
                    let error
                        as SiteReferenceResolutionError
                {
                    try Expect.equal(
                        error,
                        .sourceNotFound(
                            "missing"
                        ),
                        "site-semantics.missing-source"
                    )
                }
            }

            Step(
                "site projection rejects globally valid relationships when source or destination does not exist in the selected environment"
            ) {
                let destinationExcluded =
                    DeclaredSite(
                        pages:
                            siteSemanticsProjectionFailureGraph(),
                        references: [
                            siteSemanticsReference(
                                from:
                                    "home",
                                to:
                                    "private"
                            ),
                        ]
                    )

                let resolvedDestinationExcluded =
                    try destinationExcluded
                        .resolve()

                do {
                    _ =
                        try resolvedDestinationExcluded
                            .project(
                                in:
                                    .public
                            )

                    throw
                        SiteSemanticsFlowFailure
                            .expectedProjectionFailure
                } catch
                    let error
                        as SiteProjectionError
                {
                    try Expect.equal(
                        error,
                        .destinationNotProjected(
                            "private"
                        ),
                        "site-semantics.destination-excluded"
                    )
                }

                let sourceExcluded =
                    DeclaredSite(
                        pages:
                            siteSemanticsProjectionFailureGraph(),
                        references: [
                            siteSemanticsReference(
                                from:
                                    "local-source",
                                to:
                                    "public-destination"
                            ),
                        ]
                    )

                let resolvedSourceExcluded =
                    try sourceExcluded
                        .resolve()

                do {
                    _ =
                        try resolvedSourceExcluded
                            .project(
                                in:
                                    .public
                            )

                    throw
                        SiteSemanticsFlowFailure
                            .expectedProjectionFailure
                } catch
                    let error
                        as SiteProjectionError
                {
                    try Expect.equal(
                        error,
                        .sourceNotProjected(
                            "local-source"
                        ),
                        "site-semantics.source-excluded"
                    )
                }
            }

            Step(
                "site projection retains exact resolved-reference provenance and supports declared-reference lookup"
            ) {
                let resolved =
                    try siteSemanticsDeclaration()
                        .resolve()

                let projection =
                    try resolved
                        .project(
                            in:
                                .public
                        )

                try Expect.equal(
                    projection
                        .references
                        .count,
                    resolved
                        .references
                        .count,
                    "site-semantics.projected-reference-count"
                )

                try Expect.equal(
                    projection
                        .references[
                            0
                        ]
                        .resolved,
                    resolved
                        .references[
                            0
                        ],
                    "site-semantics.exact-reference-provenance"
                )

                guard
                    let contact =
                        projection
                            .reference(
                                .to(
                                    "contact"
                                ),
                                from:
                                    "home"
                            )
                else {
                    throw
                        SiteSemanticsFlowFailure
                            .missingProjectedReference
                }

                try Expect.equal(
                    contact
                        .resolved,
                    resolved
                        .references[
                            0
                        ],
                    "site-semantics.lookup-provenance"
                )

                guard
                    let about =
                        projection
                            .reference(
                                .to(
                                    "about",
                                    style:
                                        .local(
                                            .relative
                                        )
                                ),
                                from:
                                    "home"
                            )
                else {
                    throw
                        SiteSemanticsFlowFailure
                            .missingProjectedReference
                }

                try Expect.equal(
                    about
                        .style,
                    .local(
                        .relative
                    ),
                    "site-semantics.lookup-style-identity"
                )
            }

            Step(
                "RenderContext lowers declared projected relationships without performing semantic resolution"
            ) {
                let projection =
                    try siteSemanticsDeclaration()
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

                let contact =
                    try context
                        .render(
                            .to(
                                "contact"
                            ),
                            from:
                                "home"
                        )

                try Expect.equal(
                    contact
                        .href,
                    "/contact/",
                    "site-semantics.rendered-declared-reference"
                )

                try Expect.equal(
                    contact
                        .projected
                        .resolved,
                    projection
                        .references[
                            0
                        ]
                        .resolved,
                    "site-semantics.rendered-reference-provenance"
                )

                let about =
                    try context
                        .render(
                            .to(
                                "about",
                                style:
                                    .local(
                                        .relative
                                    )
                            ),
                            from:
                                "home"
                        )

                try Expect.equal(
                    about
                        .href,
                    "about/",
                    "site-semantics.rendered-relative-reference"
                )
            }

            Step(
                "RenderContext cannot invent an undeclared relationship between otherwise valid projected pages"
            ) {
                let projection =
                    try siteSemanticsDeclaration()
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
                                .to(
                                    "about"
                                ),
                                from:
                                    "contact"
                            )

                    throw
                        SiteSemanticsFlowFailure
                            .expectedRenderReferenceFailure
                } catch
                    let error
                        as RenderContextReferenceError
                {
                    try Expect.equal(
                        error,
                        .referenceNotProjected(
                            source:
                                "contact",
                            destination:
                                "about"
                        ),
                        "site-semantics.undeclared-reference"
                    )
                }
            }

            Step(
                "zero-reference DeclaredSite preserves the existing graph-only projection behavior"
            ) {
                let graph =
                    siteSemanticsGraph()

                let graphProjection =
                    try graph
                        .resolve()
                        .project(
                            in:
                                .public
                        )

                let siteProjection =
                    try DeclaredSite(
                        pages:
                            graph
                    )
                    .resolve()
                    .project(
                        in:
                            .public
                    )

                try Expect.equal(
                    siteProjection
                        .pages
                        .map {
                            $0
                                .identifier
                                .rawValue
                        },
                    graphProjection
                        .pages
                        .map {
                            $0
                                .identifier
                                .rawValue
                        },
                    "site-semantics.zero-reference-pages"
                )

                try Expect.equal(
                    siteProjection
                        .pages
                        .map {
                            $0
                                .siteRoute
                        },
                    graphProjection
                        .pages
                        .map {
                            $0
                                .siteRoute
                        },
                    "site-semantics.zero-reference-routes"
                )

                try Expect.equal(
                    graphProjection
                        .references
                        .isEmpty,
                    true,
                    "site-semantics.graph-projection-reference-free"
                )

                try Expect.equal(
                    siteProjection
                        .references
                        .isEmpty,
                    true,
                    "site-semantics.zero-reference-site"
                )
            }
        }
}

private struct SiteSemanticsPageIdentifier:
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

private struct SiteSemanticsPage:
    PageGraphNode
{
    let identifier:
        SiteSemanticsPageIdentifier

    let slug:
        PathSegment?

    let title:
        String

    let visibility:
        Set<BuildEnvironment>

    let children:
        [SiteSemanticsPage]

    init(
        identifier:
            SiteSemanticsPageIdentifier,
        slug:
            PathSegment?,
        title:
            String,
        visibility:
            Set<BuildEnvironment>,
        children:
            [SiteSemanticsPage] = []
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

private func siteSemanticsDeclaration()
    -> DeclaredSite<
        SiteSemanticsPage
    >
{
    DeclaredSite(
        pages:
            siteSemanticsGraph(),
        references: [
            siteSemanticsReference(
                from:
                    "home",
                to:
                    "contact"
            ),

            siteSemanticsReference(
                from:
                    "home",
                to:
                    "about",
                style:
                    .local(
                        .relative
                    )
            ),
        ]
    )
}

private func siteSemanticsGraph()
    -> PageGraph<
        SiteSemanticsPage
    >
{
    PageGraph(
        roots: [
            SiteSemanticsPage(
                identifier:
                    "home",
                slug:
                    nil,
                title:
                    "Home",
                visibility:
                    siteSemanticsAllEnvironments,
                children: [
                    SiteSemanticsPage(
                        identifier:
                            "contact",
                        slug:
                            siteSemanticsSegment(
                                "contact"
                            ),
                        title:
                            "Contact",
                        visibility:
                            siteSemanticsAllEnvironments
                    ),

                    SiteSemanticsPage(
                        identifier:
                            "about",
                        slug:
                            siteSemanticsSegment(
                                "about"
                            ),
                        title:
                            "About",
                        visibility:
                            siteSemanticsAllEnvironments
                    ),
                ]
            ),
        ]
    )
}

private func siteSemanticsProjectionFailureGraph()
    -> PageGraph<
        SiteSemanticsPage
    >
{
    PageGraph(
        roots: [
            SiteSemanticsPage(
                identifier:
                    "home",
                slug:
                    nil,
                title:
                    "Home",
                visibility:
                    siteSemanticsAllEnvironments,
                children: [
                    SiteSemanticsPage(
                        identifier:
                            "private",
                        slug:
                            siteSemanticsSegment(
                                "private"
                            ),
                        title:
                            "Private",
                        visibility: [
                            .local,
                        ]
                    ),

                    SiteSemanticsPage(
                        identifier:
                            "local-source",
                        slug:
                            siteSemanticsSegment(
                                "local-source"
                            ),
                        title:
                            "Local source",
                        visibility: [
                            .local,
                        ]
                    ),

                    SiteSemanticsPage(
                        identifier:
                            "public-destination",
                        slug:
                            siteSemanticsSegment(
                                "public-destination"
                            ),
                        title:
                            "Public destination",
                        visibility: [
                            .public,
                        ]
                    ),
                ]
            ),
        ]
    )
}

private func siteSemanticsReference(
    from source:
        SiteSemanticsPageIdentifier,
    to destination:
        SiteSemanticsPageIdentifier,
    style:
        SiteReferenceStyle = .automatic
) -> SiteReferenceDeclaration<
    SiteSemanticsPageIdentifier
> {
    SiteReferenceDeclaration(
        source:
            source,
        reference:
            .to(
                destination,
                style:
                    style
            )
    )
}

private var siteSemanticsAllEnvironments:
    Set<BuildEnvironment>
{
    [
        .local,
        .test,
        .public,
    ]
}

private func siteSemanticsSegment(
    _ value:
        String
) -> PathSegment {
    PathSegment(
        value,
        .directory
    )
}

private enum SiteSemanticsFlowFailure:
    Error
{
    case expectedResolutionFailure
    case expectedProjectionFailure
    case expectedRenderReferenceFailure
    case missingProjectedReference
}
