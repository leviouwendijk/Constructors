import CSS
import JS

/// Resolved dependency state retained across the rendering boundary.
///
/// Dependency identity has already been resolved by the owning CSS and JS
/// libraries. Constructors groups those results without flattening them into
/// anonymous stylesheets, scripts, or textual output.
public struct RenderDependencies:
    Sendable,
    Equatable
{
    public let styles:
        ResolvedCSSContributions

    public let scripts:
        ResolvedJSContributions

    public init(
        styles:
            ResolvedCSSContributions,
        scripts:
            ResolvedJSContributions
    ) {
        self.styles =
            styles

        self.scripts =
            scripts
    }
}
