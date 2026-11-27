import CSS
import DSL
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
    /// Asset keys in first-use order, each once.
    public let assets:
        [StructuredContent.AssetKey]

    public init(
        styles:
            ResolvedCSSContributions,
        scripts:
            ResolvedJSContributions,
        assets:
            [StructuredContent.AssetKey] = []
    ) {
        var seen: Set<StructuredContent.AssetKey> = []
        self.assets =
            assets.filter {
                seen.insert($0).inserted
            }
        self.styles =
            styles

        self.scripts =
            scripts
    }
}
