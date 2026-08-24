import CSS
import Constructors
import HTML
import JS
import Path
import Primitives
import TestFlows

extension ConstructorsFlowSuite {
    static let componentSemantics =
        TestFlow(
            "component-semantics",
            title:
                "Components retain terminal content, CSS/JS dependency identity, and site references until their owning semantic stages",
            tags: [
                "component",
                "constructors",
                "css",
                "javascript",
                "reference",
                "resolution",
                "semantic",
                "site",
            ]
        ) {
            Step(
                "markup-only component needs no page identifier or browser dependency"
            ) {
                let output =
                    MarkupOnlyComponent()
                        .output()

                try Expect.equal(
                    output
                        .content
                        .head
                        .count,
                    0,
                    "component.markup.head"
                )

                try Expect.equal(
                    output
                        .content
                        .body
                        .count,
                    1,
                    "component.markup.body"
                )

                try Expect.equal(
                    output
                        .dependencies
                        .styles
                        .contributions
                        .count,
                    0,
                    "component.markup.styles"
                )

                try Expect.equal(
                    output
                        .dependencies
                        .scripts
                        .contributions
                        .count,
                    0,
                    "component.markup.scripts"
                )
            }

            Step(
                "CSS and JavaScript owning component retains unresolved contribution identity"
            ) {
                let output =
                    InteractiveComponent()
                        .output()

                try Expect.equal(
                    output
                        .content
                        .body
                        .count,
                    1,
                    "component.interactive.body"
                )

                try Expect.equal(
                    output
                        .dependencies
                        .styles
                        .contributions
                        .count,
                    1,
                    "component.interactive.styles-unresolved"
                )

                try Expect.equal(
                    output
                        .dependencies
                        .scripts
                        .contributions
                        .count,
                    1,
                    "component.interactive.scripts-unresolved"
                )
            }

            Step(
                "component composition preserves duplicates until CSS and JS Resolution"
            ) {
                let component =
                    InteractiveComponent()

                let merged =
                    component
                        .output()
                        .merging(
                            component
                                .output()
                        )

                try Expect.equal(
                    merged
                        .dependencies
                        .styles
                        .contributions
                        .count,
                    2,
                    "component.merge.css-before-resolution"
                )

                try Expect.equal(
                    merged
                        .dependencies
                        .scripts
                        .contributions
                        .count,
                    2,
                    "component.merge.js-before-resolution"
                )

                let resolvedStyles =
                    try merged
                        .dependencies
                        .styles
                        .resolve()

                let resolvedScripts =
                    try merged
                        .dependencies
                        .scripts
                        .resolve()

                try Expect.equal(
                    resolvedStyles
                        .contributions
                        .count,
                    1,
                    "component.merge.css-after-resolution"
                )

                try Expect.equal(
                    resolvedScripts
                        .contributions
                        .count,
                    1,
                    "component.merge.js-after-resolution"
                )
            }

            Step(
                "component composition delegates same-identity conflicts to CSS and JS"
            ) {
                let first =
                    InteractiveComponent(
                        display:
                            "block",
                        script:
                            "window.componentInteractive = true;"
                    )
                        .output()

                let conflicting =
                    InteractiveComponent(
                        display:
                            "grid",
                        script:
                            "window.componentInteractive = false;"
                    )
                        .output()

                let merged =
                    first
                        .merging(
                            conflicting
                        )

                let cssConflictDetected:
                    Bool

                do {
                    _ =
                        try merged
                            .dependencies
                            .styles
                            .resolve()

                    cssConflictDetected =
                        false
                } catch {
                    cssConflictDetected =
                        true
                }

                let jsConflictDetected:
                    Bool

                do {
                    _ =
                        try merged
                            .dependencies
                            .scripts
                            .resolve()

                    jsConflictDetected =
                        false
                } catch {
                    jsConflictDetected =
                        true
                }

                try Expect.equal(
                    cssConflictDetected,
                    true,
                    "component.conflict.css"
                )

                try Expect.equal(
                    jsConflictDetected,
                    true,
                    "component.conflict.js"
                )
            }

            Step(
                "site-aware composition binds destination reference to source page before Resolution"
            ) {
                let component =
                    LinkingComponent()
                        .siteComponent(
                            source:
                                "home"
                        )

                try Expect.equal(
                    component
                        .referenceDeclarations
                        .count,
                    1,
                    "component.reference.declaration-count"
                )

                guard
                    let declaration =
                        component
                            .referenceDeclarations
                            .first
                else {
                    throw
                        ComponentSemanticsFlowFailure
                            .missingReferenceDeclaration
                }

                try Expect.equal(
                    declaration
                        .source
                        .rawValue,
                    "home",
                    "component.reference.source"
                )

                try Expect.equal(
                    declaration
                        .reference
                        .destination
                        .rawValue,
                    "contact",
                    "component.reference.destination"
                )

                try Expect.equal(
                    component
                        .content
                        .body
                        .count,
                    1,
                    "component.reference.content-remains-separate"
                )
            }

            Step(
                "component-discovered references enter the existing site Resolution and Projection lifecycle"
            ) {
                let component =
                    LinkingComponent()
                        .siteComponent(
                            source:
                                "home"
                        )

                let site =
                    DeclaredSite(
                        pages:
                            componentGraph(),
                        references:
                            component
                                .referenceDeclarations
                    )

                let projection =
                    try site
                        .resolve()
                        .project(
                            in:
                                .public
                        )

                let semanticReference:
                    SiteReference<
                        ComponentPageIdentifier
                    > =
                    .to(
                        "contact"
                    )

                try Expect.equal(
                    projection
                        .reference(
                            semanticReference,
                            from:
                                "home"
                        )
                        != nil,
                    true,
                    "component.reference.projected"
                )
            }

            Step(
                "component-discovered reference cannot bypass Projection visibility"
            ) {
                let component =
                    HiddenLinkingComponent()
                        .siteComponent(
                            source:
                                "home"
                        )

                let resolved =
                    try DeclaredSite(
                        pages:
                            componentGraph(),
                        references:
                            component
                                .referenceDeclarations
                    )
                        .resolve()

                let publicProjectionRejected:
                    Bool

                do {
                    _ =
                        try resolved
                            .project(
                                in:
                                    .public
                            )

                    publicProjectionRejected =
                        false
                } catch {
                    publicProjectionRejected =
                        true
                }

                try Expect.equal(
                    publicProjectionRejected,
                    true,
                    "component.reference.public-hidden"
                )

                let localProjection =
                    try resolved
                        .project(
                            in:
                                .local
                        )

                let semanticReference:
                    SiteReference<
                        ComponentPageIdentifier
                    > =
                    .to(
                        "hidden"
                    )

                try Expect.equal(
                    localProjection
                        .reference(
                            semanticReference,
                            from:
                                "home"
                        )
                        != nil,
                    true,
                    "component.reference.local-visible"
                )
            }

            Step(
                "site-aware component retains CSS and JS contributions without resolving them"
            ) {
                let output =
                    InteractiveComponent()
                        .output()

                let component =
                    SiteComponent<
                        ComponentPageIdentifier
                    >(
                        source:
                            "home",
                        output:
                            output,
                        references: [
                            .to(
                                "contact"
                            ),
                        ]
                    )

                try Expect.equal(
                    component
                        .contribution
                        .references
                        .count,
                    1,
                    "component.site.references"
                )

                try Expect.equal(
                    component
                        .contribution
                        .styles
                        .contributions
                        .count,
                    1,
                    "component.site.styles"
                )

                try Expect.equal(
                    component
                        .contribution
                        .scripts
                        .contributions
                        .count,
                    1,
                    "component.site.scripts"
                )
            }
        }
}

private struct MarkupOnlyComponent:
    Sendable
{
    func output()
        -> ComponentOutput
    {
        ComponentOutput(
            content:
                ComponentContent(
                    body: [
                        HTML.p {
                            HTML.text(
                                "Markup only"
                            )
                        },
                    ]
                )
        )
    }
}

private struct InteractiveComponent:
    Sendable
{
    let display:
        String

    let script:
        String

    init(
        display:
            String = "block",
        script:
            String =
                "window.componentInteractive = true;"
    ) {
        self.display =
            display

        self.script =
            script
    }

    func output()
        -> ComponentOutput
    {
        ComponentOutput(
            content:
                ComponentContent(
                    body: [
                        HTML.div(
                            [
                                "class":
                                    "component-interactive",
                            ]
                        ) {
                            HTML.text(
                                "Interactive"
                            )
                        },
                    ]
                ),
            dependencies:
                ComponentDependencies(
                    styles:
                        CSSContributions(
                            [
                                interactiveStyle(
                                    display:
                                        display
                                ),
                            ]
                        ),
                    scripts:
                        JSContributions(
                            [
                                interactiveScript(
                                    source:
                                        script
                                ),
                            ]
                        )
                )
        )
    }
}

private enum ComponentStyleIdentity:
    String,
    CSSContributionIdentifying
{
    case interactive =
        "component-interactive"
}

private func interactiveStyle(
    display:
        String
) -> CSSContribution {
    CSS.contribution(
        ComponentStyleIdentity
            .interactive
    ) {
        CSS.rule(
            ".component-interactive",
            CSS.decl(
                "display",
                CSSValue.raw(
                    display
                )
            )
        )
    }
}

private func interactiveScript(
    source:
        String
) -> JSContribution {
    JSContribution(
        identifier:
            "component-interactive",
        script:
            .inline(
                JSSource(
                    source
                )
            )
    )
}

private struct LinkingComponent:
    Sendable
{
    func siteComponent(
        source:
            ComponentPageIdentifier
    ) -> SiteComponent<
        ComponentPageIdentifier
    > {
        SiteComponent(
            source:
                source,
            output:
                ComponentOutput(
                    content:
                        ComponentContent(
                            body: [
                                HTML.p {
                                    HTML.text(
                                        "Contact link"
                                    )
                                },
                            ]
                        )
                ),
            references: [
                .to(
                    "contact"
                ),
            ]
        )
    }
}

private struct HiddenLinkingComponent:
    Sendable
{
    func siteComponent(
        source:
            ComponentPageIdentifier
    ) -> SiteComponent<
        ComponentPageIdentifier
    > {
        SiteComponent(
            source:
                source,
            output:
                .empty,
            references: [
                .to(
                    "hidden"
                ),
            ]
        )
    }
}

private struct ComponentPageIdentifier:
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

private struct ComponentPage:
    PageGraphNode
{
    let identifier:
        ComponentPageIdentifier

    let slug:
        PathSegment?

    let title:
        String

    let visibility:
        Set<
            BuildEnvironment
        >

    let children:
        [
            ComponentPage
        ]

    init(
        identifier:
            ComponentPageIdentifier,
        slug:
            PathSegment?,
        title:
            String,
        visibility:
            Set<
                BuildEnvironment
            >,
        children:
            [
                ComponentPage
            ] = []
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

private func componentGraph()
    -> PageGraph<
        ComponentPage
    >
{
    PageGraph(
        roots: [
            ComponentPage(
                identifier:
                    "home",
                slug:
                    nil,
                title:
                    "Home",
                visibility:
                    componentAllEnvironments,
                children: [
                    ComponentPage(
                        identifier:
                            "contact",
                        slug:
                            componentSegment(
                                "contact"
                            ),
                        title:
                            "Contact",
                        visibility:
                            componentAllEnvironments
                    ),

                    ComponentPage(
                        identifier:
                            "hidden",
                        slug:
                            componentSegment(
                                "hidden"
                            ),
                        title:
                            "Hidden",
                        visibility: [
                            .local,
                        ]
                    ),
                ]
            ),
        ]
    )
}

private var componentAllEnvironments:
    Set<
        BuildEnvironment
    >
{
    [
        .local,
        .test,
        .public,
    ]
}

private func componentSegment(
    _ value:
        String
) -> PathSegment {
    PathSegment(
        value,
        .directory
    )
}

private enum ComponentSemanticsFlowFailure:
    Error
{
    case missingReferenceDeclaration
}
