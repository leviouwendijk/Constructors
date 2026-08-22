import CSS
import Constructors
import HTML
import JS
import Path
import Primitives
import TestFlows

extension ConstructorsFlowSuite {
    static let staticDocumentDependencyIntegration =
        TestFlow(
            "static-document-dependency-integration",
            title:
                "Static dependency integration connects packaged resources to structural HTML before serialization",
            tags: [
                "constructors",
                "css",
                "dependencies",
                "document",
                "html",
                "javascript",
                "materialization",
                "static",
            ]
        ) {
            Step(
                "site packaging integrates one stylesheet reference and only each document's own scripts"
            ) {
                let plan =
                    try integrationFixturePlan()

                let integrated =
                    try StaticDocumentDependencyIntegrator()
                        .integrate(
                            plan
                        )

                try Expect.equal(
                    integrated
                        .documents
                        .count,
                    2,
                    "static-integration.document-count"
                )

                guard
                    let home =
                        integrated
                            .documents
                            .first(
                                where: {
                                    $0
                                        .identifier
                                        .rawValue
                                        == "home"
                                }
                            ),
                    let contact =
                        integrated
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
                        StaticIntegrationFlowFailure
                            .missingPage(
                                "home/contact"
                            )
                }

                try Expect.equal(
                    home
                        .stylesheet
                        .href,
                    "/assets/css/site.css",
                    "static-integration.default-stylesheet-href"
                )

                try Expect.equal(
                    contact
                        .stylesheet
                        .href,
                    "/assets/css/site.css",
                    "static-integration.shared-stylesheet-href"
                )

                try Expect.equal(
                    home
                        .scripts
                        .map {
                            $0
                                .identifier
                                .rawValue
                        },
                    [
                        "integration-shared",
                        "integration-home-external",
                    ],
                    "static-integration.home-script-membership-order"
                )

                try Expect.equal(
                    contact
                        .scripts
                        .map {
                            $0
                                .identifier
                                .rawValue
                        },
                    [
                        "integration-contact-inline",
                        "integration-shared",
                    ],
                    "static-integration.contact-local-script-order"
                )

                let homeHTML =
                    home
                        .document
                        .render(
                            options:
                                HTMLRenderOptions
                                    .Defaults
                                    .minified()
                        )

                let contactHTML =
                    contact
                        .document
                        .render(
                            options:
                                HTMLRenderOptions
                                    .Defaults
                                    .minified()
                        )

                for required in [
                    "Home Fixture",
                    "/assets/css/site.css",
                    "window.integrationShared = true;",
                    "/assets/vendor-home.js",
                    "type=\"module\"",
                    "nonce=\"shared-nonce\"",
                    "defer",
                    "integrity=\"sha256-home-fixture\"",
                    "crossorigin=\"anonymous\"",
                    "nonce=\"external-nonce\"",
                ] {
                    try Expect.equal(
                        homeHTML
                            .contains(
                                required
                            ),
                        true,
                        "static-integration.home-html-\(required)"
                    )
                }

                try Expect.equal(
                    homeHTML
                        .contains(
                            "window.integrationContact = true;"
                        ),
                    false,
                    "static-integration.home-excludes-contact-script"
                )

                for required in [
                    "Contact Fixture",
                    "/assets/css/site.css",
                    "window.integrationContact = true;",
                    "window.integrationShared = true;",
                ] {
                    try Expect.equal(
                        contactHTML
                            .contains(
                                required
                            ),
                        true,
                        "static-integration.contact-html-\(required)"
                    )
                }

                try Expect.equal(
                    contactHTML
                        .contains(
                            "/assets/vendor-home.js"
                        ),
                    false,
                    "static-integration.contact-excludes-home-script"
                )
            }

            Step(
                "public stylesheet href remains distinct from physical stylesheet output"
            ) {
                let plan =
                    try integrationFixturePlan()

                let integrated =
                    try StaticDocumentDependencyIntegrator(
                        policy:
                            StaticDocumentDependencyIntegrationPolicy(
                                stylesheetHref:
                                    "/static/v2/application.css"
                            )
                    )
                    .integrate(
                        plan
                    )

                guard
                    let home =
                        integrated
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
                        StaticIntegrationFlowFailure
                            .missingPage(
                                "home"
                            )
                }

                try Expect.equal(
                    home
                        .stylesheet
                        .href,
                    "/static/v2/application.css",
                    "static-integration.custom-public-stylesheet-reference"
                )

                try Expect.equal(
                    home
                        .stylesheet
                        .output,
                    StandardPath(
                        [
                            "assets",
                            "css",
                            "site",
                        ],
                        filetype:
                            .text(
                                .css
                            )
                    ),
                    "static-integration.physical-stylesheet-output-unchanged"
                )

                let html =
                    home
                        .document
                        .render(
                            options:
                                HTMLRenderOptions
                                    .Defaults
                                    .minified()
                        )

                try Expect.equal(
                    html
                        .contains(
                            "/static/v2/application.css"
                        ),
                    true,
                    "static-integration.custom-href-lowered-structurally"
                )

                try Expect.equal(
                    html
                        .contains(
                            "/assets/css/site.css"
                        ),
                    false,
                    "static-integration.no-implicit-output-to-href-coupling"
                )
            }

            Step(
                "inline and external JavaScript placement is policy while JSScript semantics remain unchanged"
            ) {
                let plan =
                    try integrationFixturePlan()

                let integrated =
                    try StaticDocumentDependencyIntegrator(
                        policy:
                            StaticDocumentDependencyIntegrationPolicy(
                                inlineScriptPlacement:
                                    .bodyEnd,
                                externalScriptPlacement:
                                    .headEnd
                            )
                    )
                    .integrate(
                        plan
                    )

                guard
                    let home =
                        integrated
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
                        StaticIntegrationFlowFailure
                            .missingPage(
                                "home"
                            )
                }

                let html =
                    home
                        .document
                        .render(
                            options:
                                HTMLRenderOptions
                                    .Defaults
                                    .minified()
                        )

                guard
                    let headEnd =
                        html
                            .range(
                                of:
                                    "</head>"
                            ),
                    let external =
                        html
                            .range(
                                of:
                                    "/assets/vendor-home.js"
                            ),
                    let inline =
                        html
                            .range(
                                of:
                                    "window.integrationShared = true;"
                            )
                else {
                    throw
                        StaticIntegrationFlowFailure
                            .missingHTMLBoundary
                }

                try Expect.equal(
                    external
                        .lowerBound
                        < headEnd
                            .lowerBound,
                    true,
                    "static-integration.external-script-in-head"
                )

                try Expect.equal(
                    inline
                        .lowerBound
                        > headEnd
                            .lowerBound,
                    true,
                    "static-integration.inline-script-in-body"
                )

                try Expect.equal(
                    home
                        .scripts[0]
                        .script,
                    integrationSharedScript(),
                    "static-integration.inline-jsscript-unchanged"
                )

                try Expect.equal(
                    home
                        .scripts[1]
                        .script,
                    integrationHomeExternalScript(),
                    "static-integration.external-jsscript-unchanged"
                )
            }

            Step(
                "integration rejects a document dependency absent from canonical site packaging"
            ) {
                let plan =
                    try integrationFixturePlan()

                guard
                    let home =
                        plan
                            .site
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
                        StaticIntegrationFlowFailure
                            .missingPage(
                                "home"
                            )
                }

                let incompletePackaging =
                    StaticDependencyPackaging(
                        stylesheet:
                            plan
                                .dependencies
                                .stylesheet,
                        scripts:
                            plan
                                .dependencies
                                .scripts
                                .filter {
                                    $0
                                        .identifier
                                        .rawValue
                                        != "integration-home-external"
                                }
                    )

                do {
                    _ =
                        try StaticDocumentDependencyIntegrator()
                            .integrate(
                                home,
                                packaging:
                                    incompletePackaging
                            )

                    throw
                        StaticIntegrationFlowFailure
                            .expectedIntegrationFailure
                } catch
                    let error
                        as StaticDocumentDependencyIntegrationError
                {
                    try Expect.equal(
                        error,
                        .missingPackagedScript(
                            "integration-home-external"
                        ),
                        "static-integration.missing-packaged-script-detected"
                    )
                }
            }
        }
}

private func integrationFixturePlan()
    throws -> StaticSiteMaterializationPlan<
        IntegrationPage
    >
{
    let projection =
        try integrationGraph()
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
            StaticIntegrationFlowFailure
                .missingPage(
                    "home/contact"
                )
    }

    let homeDependencies =
        try integrationDependencies(
            scripts: [
                JSContribution(
                    identifier:
                        "integration-shared",
                    script:
                        integrationSharedScript()
                ),
                JSContribution(
                    identifier:
                        "integration-home-external",
                    script:
                        integrationHomeExternalScript()
                ),
            ]
        )

    /// Deliberately put the contact-specific script before the shared script.
    ///
    /// Site-level packaging sees the shared script first through the home
    /// document, so this proves integration restores document-local ordering
    /// rather than blindly filtering the site's canonical packaging order.
    let contactDependencies =
        try integrationDependencies(
            scripts: [
                JSContribution(
                    identifier:
                        "integration-contact-inline",
                    script:
                        integrationContactScript()
                ),
                JSContribution(
                    identifier:
                        "integration-shared",
                    script:
                        integrationSharedScript()
                ),
            ]
        )

    let rendered =
        try SiteRenderResult(
            projection:
                projection,
            documents: [
                RenderedDocument(
                    projectedPage:
                        home,
                    document:
                        integrationDocument(
                            title:
                                "Home Fixture"
                        ),
                    dependencies:
                        homeDependencies
                ),
                RenderedDocument(
                    projectedPage:
                        contact,
                    document:
                        integrationDocument(
                            title:
                                "Contact Fixture"
                        ),
                    dependencies:
                        contactDependencies
                ),
            ]
        )

    let documents =
        StaticDocumentMaterializer()
            .materialize(
                rendered
            )

    return
        StaticDependencyPackager()
            .pack(
                documents
            )
}

private func integrationDependencies(
    scripts:
        [JSContribution]
) throws -> RenderDependencies {
    RenderDependencies(
        styles:
            try CSSContributions(
                [
                    CSSContribution(
                        identifier:
                            "integration-style",
                        content:
                            CSSContributionSet(
                                units:
                                    []
                            )
                    ),
                ]
            )
            .resolve(),
        scripts:
            try JSContributions(
                scripts
            )
            .resolve()
    )
}

private func integrationSharedScript()
    -> JSScript
{
    .inline(
        JSSource(
            "window.integrationShared = true;"
        ),
        attributes:
            JSScriptAttributes(
                kind:
                    .module,
                nonce:
                    "shared-nonce"
            )
    )
}

private func integrationHomeExternalScript()
    -> JSScript
{
    .external(
        JSExternalSource(
            "/assets/vendor-home.js"
        ),
        attributes:
            JSScriptAttributes(
                defer_loading:
                    true,
                integrity:
                    "sha256-home-fixture",
                crossorigin:
                    "anonymous",
                nonce:
                    "external-nonce"
            )
    )
}

private func integrationContactScript()
    -> JSScript
{
    .inline(
        JSSource(
            "window.integrationContact = true;"
        )
    )
}

private func integrationDocument(
    title:
        String
) -> HTMLDocument {
    HTMLDocument(
        attributes:
            .empty,
        head: [
            HTML.title(
                title
            ),
        ],
        body:
            []
    )
}

private func integrationGraph()
    -> PageGraph<
        IntegrationPage
    >
{
    PageGraph(
        roots: [
            IntegrationPage(
                identifier:
                    "home",
                slug:
                    nil,
                title:
                    "Home",
                children: [
                    IntegrationPage(
                        identifier:
                            "contact",
                        slug:
                            PathSegment(
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

private struct IntegrationPageIdentifier:
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

private struct IntegrationPage:
    PageGraphNode
{
    let identifier:
        IntegrationPageIdentifier

    let slug:
        PathSegment?

    let title:
        String

    let visibility:
        Set<BuildEnvironment>

    let children:
        [IntegrationPage]

    init(
        identifier:
            IntegrationPageIdentifier,
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
            [IntegrationPage] = []
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

private enum StaticIntegrationFlowFailure:
    Error
{
    case missingPage(
        String
    )

    case missingHTMLBoundary

    case expectedIntegrationFailure
}
