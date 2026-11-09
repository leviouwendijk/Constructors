import CSS
import JS
import Primitives

/// Site-aware semantic contribution authored before Resolution.
///
/// References remain unresolved semantic destinations. CSS and JavaScript
/// dependencies remain unresolved contribution collections. No href, rendered
/// text, filesystem path, or transport representation is produced here.
public struct ComponentContribution<
    Identifier:
        StringIdentifier
>:
    Sendable
{
    public let references:
        [
            SiteReference<
                Identifier
            >
        ]

    public let styles:
        CSSContributions

    public let scripts:
        JSContributions

    public init(
        references:
            [
                SiteReference<
                    Identifier
                >
            ] = [],
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
        self.references =
            references

        self.styles =
            styles

        self.scripts =
            scripts
    }

    public init(
        references:
            [
                SiteReference<
                    Identifier
                >
            ] = [],
        dependencies:
            ComponentDependencies
    ) {
        self.init(
            references:
                references,
            styles:
                dependencies
                    .styles,
            scripts:
                dependencies
                    .scripts
        )
    }

    public func merging(
        _ other:
            ComponentContribution<
                Identifier
            >
    ) -> ComponentContribution<
        Identifier
    > {
        ComponentContribution(
            references:
                references
                + other.references,
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
