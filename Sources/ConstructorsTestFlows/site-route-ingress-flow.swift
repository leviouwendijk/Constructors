import Constructors
import Path
import Primitives
import TestFlows

extension ConstructorsFlowSuite {
    static let siteRouteIngress =
        TestFlow(
            "site-route-ingress",
            title:
                "External path components parse into SiteRoute identity and address only pages that exist in one SiteProjection",
            tags: [
                "constructors",
                "ingress",
                "projection",
                "route",
                "semantic",
            ]
        ) {
            Step(
                "root path parses into canonical root route"
            ) {
                let route =
                    try SiteRoute(
                        parsingPath:
                            "/"
                    )

                try Expect.equal(
                    route,
                    .root,
                    "route-ingress.root"
                )

                try Expect.equal(
                    route
                        .href,
                    "/",
                    "route-ingress.root-href"
                )
            }

            Step(
                "nested paths with or without trailing slash become the same semantic route"
            ) {
                let projection =
                    try routeIngressGraph()
                        .resolve()
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
                        RouteIngressFlowFailure
                            .missingFixturePage(
                                "agreement"
                            )
                }

                let canonicalInput =
                    try SiteRoute(
                        parsingPath:
                            "/account/agreement/"
                    )

                let nonTrailingInput =
                    try SiteRoute(
                        parsingPath:
                            "/account/agreement"
                    )

                try Expect.equal(
                    canonicalInput,
                    agreement
                        .siteRoute,
                    "route-ingress.nested-canonical"
                )

                try Expect.equal(
                    nonTrailingInput,
                    agreement
                        .siteRoute,
                    "route-ingress.nested-no-trailing-slash"
                )

                try Expect.equal(
                    canonicalInput,
                    nonTrailingInput,
                    "route-ingress.trailing-slash-normalization"
                )

                try Expect.equal(
                    nonTrailingInput
                        .href,
                    "/account/agreement/",
                    "route-ingress.canonical-href"
                )
            }

            Step(
                "malformed external path input is rejected before SiteRoute identity is established"
            ) {
                try expectRouteIngressFailure(
                    "",
                    .pathMustStartWithSlash(
                        ""
                    )
                )

                try expectRouteIngressFailure(
                    "contact/",
                    .pathMustStartWithSlash(
                        "contact/"
                    )
                )

                try expectRouteIngressFailure(
                    "/contact/?source=test",
                    .queryOrFragmentNotAllowed(
                        "/contact/?source=test"
                    )
                )

                try expectRouteIngressFailure(
                    "/contact/#details",
                    .queryOrFragmentNotAllowed(
                        "/contact/#details"
                    )
                )

                try expectRouteIngressFailure(
                    "/account//agreement/",
                    .emptySegment(
                        "/account//agreement/"
                    )
                )

                try expectRouteIngressFailure(
                    "//contact/",
                    .emptySegment(
                        "//contact/"
                    )
                )

                try expectRouteIngressFailure(
                    "/./",
                    .dotSegment(
                        path:
                            "/./",
                        segment:
                            "."
                    )
                )

                try expectRouteIngressFailure(
                    "/account/../contact/",
                    .dotSegment(
                        path:
                            "/account/../contact/",
                        segment:
                            ".."
                    )
                )
            }

            Step(
                "every projected route survives canonical href parse round trip"
            ) {
                let projection =
                    try routeIngressGraph()
                        .resolve()
                        .project(
                            in:
                                .public
                        )

                for page in projection.pages {
                    let reparsed =
                        try SiteRoute(
                            parsingPath:
                                page
                                    .siteRoute
                                    .href
                        )

                    try Expect.equal(
                        reparsed,
                        page
                            .siteRoute,
                        "route-ingress.href-round-trip-\(page.identifier.rawValue)"
                    )
                }
            }

            Step(
                "SiteProjection route lookup returns the exact projected semantic page"
            ) {
                let projection =
                    try routeIngressGraph()
                        .resolve()
                        .project(
                            in:
                                .public
                        )

                let route =
                    try SiteRoute(
                        parsingPath:
                            "/account/agreement/"
                    )

                guard
                    let page =
                        projection[
                            route:
                                route
                        ]
                else {
                    throw
                        RouteIngressFlowFailure
                            .missingRouteLookup(
                                route
                                    .href
                            )
                }

                try Expect.equal(
                    page
                        .identifier
                        .rawValue,
                    "agreement",
                    "route-ingress.lookup-identifier"
                )

                try Expect.equal(
                    page
                        .siteRoute,
                    route,
                    "route-ingress.lookup-route"
                )
            }

            Step(
                "syntactically valid routes cannot address pages excluded from this projection"
            ) {
                let graph =
                    routeIngressGraph()

                let resolved =
                    try graph
                        .resolve()

                let publicProjection =
                    resolved
                        .project(
                            in:
                                .public
                        )

                let localProjection =
                    resolved
                        .project(
                            in:
                                .local
                        )

                let privateRoute =
                    try SiteRoute(
                        parsingPath:
                            "/private/"
                    )

                try Expect.equal(
                    publicProjection[
                        route:
                            privateRoute
                    ]
                        == nil,
                    true,
                    "route-ingress.hidden-public-route"
                )

                guard
                    let localPrivate =
                        localProjection[
                            route:
                                privateRoute
                        ]
                else {
                    throw
                        RouteIngressFlowFailure
                            .missingRouteLookup(
                                privateRoute
                                    .href
                            )
                }

                try Expect.equal(
                    localPrivate
                        .identifier
                        .rawValue,
                    "private",
                    "route-ingress.local-private-route"
                )
            }

            Step(
                "syntactically valid but unknown routes remain absent from the projection"
            ) {
                let projection =
                    try routeIngressGraph()
                        .resolve()
                        .project(
                            in:
                                .public
                        )

                let missing =
                    try SiteRoute(
                        parsingPath:
                            "/not-declared/"
                    )

                try Expect.equal(
                    projection[
                        route:
                            missing
                    ]
                        == nil,
                    true,
                    "route-ingress.missing-route"
                )
            }
        }
}

private struct RouteIngressPageIdentifier:
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

private struct RouteIngressPage:
    PageGraphNode
{
    let identifier:
        RouteIngressPageIdentifier

    let slug:
        PathSegment?

    let title:
        String

    let visibility:
        Set<BuildEnvironment>

    let children:
        [RouteIngressPage]

    init(
        identifier:
            RouteIngressPageIdentifier,
        slug:
            PathSegment?,
        title:
            String,
        visibility:
            Set<BuildEnvironment>,
        children:
            [RouteIngressPage] = []
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

private func routeIngressGraph()
    -> PageGraph<
        RouteIngressPage
    >
{
    PageGraph(
        roots: [
            RouteIngressPage(
                identifier:
                    "home",
                slug:
                    nil,
                title:
                    "Home",
                visibility:
                    routeIngressAllEnvironments,
                children: [
                    RouteIngressPage(
                        identifier:
                            "account",
                        slug:
                            routeIngressSegment(
                                "account"
                            ),
                        title:
                            "Account",
                        visibility:
                            routeIngressAllEnvironments,
                        children: [
                            RouteIngressPage(
                                identifier:
                                    "agreement",
                                slug:
                                    routeIngressSegment(
                                        "agreement"
                                    ),
                                title:
                                    "Agreement",
                                visibility:
                                    routeIngressAllEnvironments
                            ),
                        ]
                    ),

                    RouteIngressPage(
                        identifier:
                            "contact",
                        slug:
                            routeIngressSegment(
                                "contact"
                            ),
                        title:
                            "Contact",
                        visibility:
                            routeIngressAllEnvironments
                    ),

                    RouteIngressPage(
                        identifier:
                            "private",
                        slug:
                            routeIngressSegment(
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
}

private func expectRouteIngressFailure(
    _ input:
        String,
    _ expected:
        SiteRouteParsingError
) throws {
    do {
        _ =
            try SiteRoute(
                parsingPath:
                    input
            )

        throw
            RouteIngressFlowFailure
                .expectedParsingFailure(
                    input
                )
    } catch
        let error
            as SiteRouteParsingError
    {
        try Expect.equal(
            error,
            expected,
            "route-ingress.invalid-\(input)"
        )
    }
}

private var routeIngressAllEnvironments:
    Set<BuildEnvironment>
{
    [
        .local,
        .test,
        .public,
    ]
}

private func routeIngressSegment(
    _ value:
        String
) -> PathSegment {
    PathSegment(
        value,
        .directory
    )
}

private enum RouteIngressFlowFailure:
    Error
{
    case expectedParsingFailure(
        String
    )

    case missingFixturePage(
        String
    )

    case missingRouteLookup(
        String
    )
}
