import Constructors
import TestFlows

extension ConstructorsFlowSuite {
    static let componentOutputProviding =
        TestFlow(
            "component-output-providing",
            title:
                "Components can expose site-independent semantic output without legacy rendering or site lifecycle concerns",
            tags: [
                "component",
                "constructors",
                "semantic",
                "compatibility",
            ]
        ) {
            Step(
                "ComponentOutputProviding exposes authoritative semantic output"
            ) {
                let fixture =
                    SemanticOutputFixture()

                let output =
                    semanticOutput(
                        of:
                            fixture
                    )

                try Expect.equal(
                    output.dependencies.styles.contributions.count,
                    0,
                    "component-output-providing.styles"
                )

                try Expect.equal(
                    output.dependencies.scripts.contributions.count,
                    0,
                    "component-output-providing.scripts"
                )
            }

            Step(
                "ComponentOutputProviding remains usable through an existential"
            ) {
                let fixture:
                    any ComponentOutputProviding =
                        SemanticOutputFixture()

                try Expect.equal(
                    fixture.output.dependencies.styles.contributions.count,
                    0,
                    "component-output-providing.existential.styles"
                )

                try Expect.equal(
                    fixture.output.dependencies.scripts.contributions.count,
                    0,
                    "component-output-providing.existential.scripts"
                )
            }
        }
}

private struct SemanticOutputFixture:
    ComponentOutputProviding
{
    let output:
        ComponentOutput =
            .empty
}

private func semanticOutput<Component>(
    of component:
        Component
) -> ComponentOutput
where
    Component:
        ComponentOutputProviding
{
    component.output
}
