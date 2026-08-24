/// Site-independent output authored by a reusable component.
///
/// A component that does not know about site navigation requires no page
/// identifier generic. It can author terminal HTML plus unresolved CSS/JS
/// dependencies and remain reusable in any site.
public struct ComponentOutput:
    Sendable
{
    public let content:
        ComponentContent

    public let dependencies:
        ComponentDependencies

    public init(
        content:
            ComponentContent =
                .empty,
        dependencies:
            ComponentDependencies =
                .empty
    ) {
        self.content =
            content

        self.dependencies =
            dependencies
    }

    public static var empty:
        ComponentOutput
    {
        ComponentOutput()
    }

    public func merging(
        _ other:
            ComponentOutput
    ) -> ComponentOutput {
        ComponentOutput(
            content:
                content
                    .merging(
                        other.content
                    ),
            dependencies:
                dependencies
                    .merging(
                        other.dependencies
                    )
        )
    }
}
