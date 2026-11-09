import CSS
import JS

/// Unresolved CSS and JavaScript dependencies authored by one or more
/// components.
///
/// Composition intentionally concatenates unresolved contribution graphs.
/// CSS and JS remain the owners of identity deduplication and conflict
/// detection at their explicit Resolution boundary.
public struct ComponentDependencies:
    Sendable
{
    public let styles:
        CSSContributions

    public let scripts:
        JSContributions

    public init(
        styles:
            CSSContributions =
                CSSContributions(
                    []
                ),
        scripts:
            JSContributions =
                JSContributions(
                    []
                )
    ) {
        self.styles =
            styles

        self.scripts =
            scripts
    }

    public static var empty:
        ComponentDependencies
    {
        ComponentDependencies()
    }

    public func merging(
        _ other:
            ComponentDependencies
    ) -> ComponentDependencies {
        ComponentDependencies(
            styles:
                CSSContributions(
                    styles
                        .contributions
                    + other
                        .styles
                        .contributions
                ),
            scripts:
                JSContributions(
                    scripts
                        .contributions
                    + other
                        .scripts
                        .contributions
                )
        )
    }
}
