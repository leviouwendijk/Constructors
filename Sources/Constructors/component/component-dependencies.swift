import CSS
import DSL
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
    /// Assets the component links to, by key; the site's asset catalog
    /// supplies them.
    public let assets:
        [StructuredContent.AssetKey]

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
                ),
        assets:
            [StructuredContent.AssetKey] = []
    ) {
        self.assets =
            assets
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
                ),
            assets:
                assets
                + other
                    .assets
        )
    }
}
