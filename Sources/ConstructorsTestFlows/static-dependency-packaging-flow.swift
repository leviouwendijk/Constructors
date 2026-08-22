import CSS
import Constructors
import JS
import Path
import TestFlows

extension ConstructorsFlowSuite {
    static let staticDependencyPackaging =
        TestFlow(
            "static-dependency-packaging",
            title:
                "Static dependency packaging establishes CSS artifact identity while preserving JavaScript semantics",
            tags: [
                "constructors",
                "css",
                "dependencies",
                "javascript",
                "materialization",
                "packaging",
                "semantic",
                "static",
            ]
        ) {
            Step(
                "default stylesheet packaging establishes physical CSS identity only after dependency resolution"
            ) {
                let fixture =
                    try dependencyPackagingFixture()

                let packaged =
                    StaticDependencyPackager()
                        .pack(
                            fixture
                                .dependencies
                        )

                try Expect.equal(
                    packaged
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
                    "static-dependency.default-css-output"
                )

                try Expect.equal(
                    packaged
                        .stylesheet
                        .selection,
                    .all,
                    "static-dependency.default-css-selection"
                )

                try Expect.equal(
                    packaged
                        .stylesheet
                        .stylesheet,
                    fixture
                        .dependencies
                        .styles
                        .collected(
                            .all
                        ),
                    "static-dependency.default-css-collection"
                )

                try Expect.equal(
                    packaged
                        .stylesheet
                        .stylesheet
                        .rules
                        .count,
                    3,
                    "static-dependency.default-css-rule-count"
                )
            }

            Step(
                "stylesheet artifact retains resolved contribution provenance"
            ) {
                let fixture =
                    try dependencyPackagingFixture()

                let packaged =
                    StaticDependencyPackager()
                        .pack(
                            fixture
                                .dependencies
                        )

                try Expect.equal(
                    packaged
                        .stylesheet
                        .sourceContributionIdentifiers
                        .map(
                            \.rawValue
                        ),
                    [
                        "dependency-base",
                        "dependency-page",
                        "dependency-admin",
                    ],
                    "static-dependency.css-source-identifiers"
                )
            }

            Step(
                "JavaScript packaging preserves contribution identity scope script kind and attributes"
            ) {
                let fixture =
                    try dependencyPackagingFixture()

                let packaged =
                    StaticDependencyPackager()
                        .pack(
                            fixture
                                .dependencies
                        )

                try Expect.equal(
                    packaged
                        .scripts
                        .map {
                            $0
                                .identifier
                                .rawValue
                        },
                    [
                        "dependency-inline",
                        "dependency-external",
                        "dependency-second-inline",
                    ],
                    "static-dependency.script-identifiers"
                )

                try Expect.equal(
                    packaged
                        .scripts[0]
                        .scope,
                    fixture
                        .dependencies
                        .scripts
                        .contributions[0]
                        .scope,
                    "static-dependency.inline-scope-preserved"
                )

                try Expect.equal(
                    packaged
                        .scripts[1]
                        .scope,
                    fixture
                        .dependencies
                        .scripts
                        .contributions[1]
                        .scope,
                    "static-dependency.external-scope-preserved"
                )

                try Expect.equal(
                    packaged
                        .scripts[2]
                        .scope,
                    fixture
                        .dependencies
                        .scripts
                        .contributions[2]
                        .scope,
                    "static-dependency.second-inline-scope-preserved"
                )

                try Expect.equal(
                    packaged
                        .scripts[0]
                        .script,
                    fixture
                        .inlineScript,
                    "static-dependency.inline-script-preserved"
                )

                try Expect.equal(
                    packaged
                        .scripts[1]
                        .script,
                    fixture
                        .externalScript,
                    "static-dependency.external-script-preserved"
                )

                try Expect.equal(
                    packaged
                        .scripts[2]
                        .script,
                    fixture
                        .secondInlineScript,
                    "static-dependency.second-inline-script-preserved"
                )
            }

            Step(
                "multiple JavaScript contributions remain distinct rather than becoming a generated bundle"
            ) {
                let fixture =
                    try dependencyPackagingFixture()

                let packaged =
                    StaticDependencyPackager()
                        .pack(
                            fixture
                                .dependencies
                        )

                try Expect.equal(
                    packaged
                        .scripts
                        .count,
                    3,
                    "static-dependency.distinct-script-count"
                )

                try Expect.equal(
                    packaged
                        .scripts
                        .map(
                            \.script
                        ),
                    [
                        fixture.inlineScript,
                        fixture.externalScript,
                        fixture.secondInlineScript,
                    ],
                    "static-dependency.distinct-script-order"
                )
            }

            Step(
                "stylesheet scope selection changes collected CSS without changing resolved dependency provenance"
            ) {
                let fixture =
                    try dependencyPackagingFixture()

                let customPolicy =
                    StaticDependencyPackagingPolicy(
                        styles:
                            StaticStylesheetPackagingPolicy(
                                output:
                                    StandardPath(
                                        [
                                            "assets",
                                            "css",
                                            "page",
                                        ],
                                        filetype:
                                            .text(
                                                .css
                                            )
                                    ),
                                selection:
                                    .scoped(
                                        "page"
                                    )
                            )
                    )

                let packaged =
                    StaticDependencyPackager(
                        policy:
                            customPolicy
                    )
                    .pack(
                        fixture
                            .dependencies
                    )

                try Expect.equal(
                    packaged
                        .stylesheet
                        .output,
                    StandardPath(
                        [
                            "assets",
                            "css",
                            "page",
                        ],
                        filetype:
                            .text(
                                .css
                            )
                    ),
                    "static-dependency.scoped-css-output"
                )

                try Expect.equal(
                    packaged
                        .stylesheet
                        .selection,
                    .scoped(
                        "page"
                    ),
                    "static-dependency.scoped-css-selection"
                )

                try Expect.equal(
                    packaged
                        .stylesheet
                        .stylesheet,
                    fixture
                        .dependencies
                        .styles
                        .collected(
                            .scoped(
                                "page"
                            )
                        ),
                    "static-dependency.scoped-css-collection"
                )

                try Expect.equal(
                    packaged
                        .stylesheet
                        .stylesheet
                        .rules
                        .count,
                    2,
                    "static-dependency.scoped-css-rule-count"
                )

                try Expect.equal(
                    packaged
                        .stylesheet
                        .sourceContributionIdentifiers
                        .map(
                            \.rawValue
                        ),
                    [
                        "dependency-base",
                        "dependency-page",
                        "dependency-admin",
                    ],
                    "static-dependency.scoped-css-provenance"
                )
            }
        }
}

private struct DependencyPackagingFixture {
    let dependencies:
        RenderDependencies

    let inlineScript:
        JSScript

    let externalScript:
        JSScript

    let secondInlineScript:
        JSScript
}

private func dependencyPackagingFixture()
    throws -> DependencyPackagingFixture
{
    let styles =
        try CSSContributions(
            [
                CSSContribution(
                    identifier:
                        "dependency-base",
                    content:
                        CSSContributionSet(
                            units: [
                                .block(
                                    .rule(
                                        CSS.rule(
                                            ".dependency-base",
                                            CSS.decl(
                                                "display",
                                                "block"
                                            )
                                        )
                                    )
                                ),
                            ]
                        )
                ),
                CSSContribution(
                    identifier:
                        "dependency-page",
                    content:
                        CSSContributionSet(
                            units: [
                                .scoped(
                                    "page",
                                    [
                                        .block(
                                            .rule(
                                                CSS.rule(
                                                    ".dependency-page",
                                                    CSS.decl(
                                                        "display",
                                                        "grid"
                                                    )
                                                )
                                            )
                                        ),
                                    ]
                                ),
                            ]
                        )
                ),
                CSSContribution(
                    identifier:
                        "dependency-admin",
                    content:
                        CSSContributionSet(
                            units: [
                                .scoped(
                                    "admin",
                                    [
                                        .block(
                                            .rule(
                                                CSS.rule(
                                                    ".dependency-admin",
                                                    CSS.decl(
                                                        "display",
                                                        "flex"
                                                    )
                                                )
                                            )
                                        ),
                                    ]
                                ),
                            ]
                        )
                ),
            ]
        )
        .resolve()

    let inlineScript =
        JSScript.inline(
            JSSource(
                "window.inlineDependency = true;"
            ),
            attributes:
                JSScriptAttributes(
                    kind:
                        .module,
                    nonce:
                        "inline-nonce"
                )
        )

    let externalScript =
        JSScript.external(
            JSExternalSource(
                "/assets/vendor.js"
            ),
            attributes:
                JSScriptAttributes(
                    defer_loading:
                        true,
                    integrity:
                        "sha256-fixture",
                    crossorigin:
                        "anonymous"
                )
        )

    let secondInlineScript =
        JSScript.inline(
            JSSource(
                "window.secondDependency = true;"
            )
        )

    let scripts =
        try JSContributions(
            [
                JSContribution(
                    identifier:
                        "dependency-inline",
                    script:
                        inlineScript
                ),
                JSContribution(
                    identifier:
                        "dependency-external",
                    scope:
                        "page",
                    script:
                        externalScript
                ),
                JSContribution(
                    identifier:
                        "dependency-second-inline",
                    script:
                        secondInlineScript
                ),
            ]
        )
        .resolve()

    return
        DependencyPackagingFixture(
            dependencies:
                RenderDependencies(
                    styles:
                        styles,
                    scripts:
                        scripts
                ),
            inlineScript:
                inlineScript,
            externalScript:
                externalScript,
            secondInlineScript:
                secondInlineScript
        )
}
