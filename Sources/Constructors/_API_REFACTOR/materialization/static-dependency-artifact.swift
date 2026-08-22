import CSS
import DSL
import JS
import Path

public struct StaticStylesheetArtifactPlan:
    Sendable,
    Equatable
{
    public let output:
        StandardPath

    public let selection:
        ScopeSelection

    /// Resolved contribution identities from which this stylesheet plan was
    /// derived. These remain authoring/materialization provenance and are not
    /// encoded into CSS syntax.
    public let sourceContributionIdentifiers:
        [CSSContributionIdentifier]

    /// Selected, still-structured CSS-domain representation.
    ///
    /// Text serialization remains a later terminal operation.
    public let stylesheet:
        CSSStyleSheet

    public init(
        output:
            StandardPath,
        selection:
            ScopeSelection,
        sourceContributionIdentifiers:
            [CSSContributionIdentifier],
        stylesheet:
            CSSStyleSheet
    ) {
        self.output =
            output

        self.selection =
            selection

        self.sourceContributionIdentifiers =
            sourceContributionIdentifiers

        self.stylesheet =
            stylesheet
    }
}

public struct StaticJavaScriptDependency:
    Sendable,
    Equatable
{
    public let identifier:
        JSContributionIdentifier

    public let scope:
        ScopeIdentifier?

    /// Existing JS-domain representation is retained exactly.
    ///
    /// `JSScript` distinguishes inline/external scripts and retains its
    /// attributes, so packaging does not erase those semantics.
    public let script:
        JSScript

    public init(
        identifier:
            JSContributionIdentifier,
        scope:
            ScopeIdentifier?,
        script:
            JSScript
    ) {
        self.identifier =
            identifier

        self.scope =
            scope

        self.script =
            script
    }
}

public struct StaticDependencyPackaging:
    Sendable,
    Equatable
{
    public let stylesheet:
        StaticStylesheetArtifactPlan

    public let scripts:
        [StaticJavaScriptDependency]

    public init(
        stylesheet:
            StaticStylesheetArtifactPlan,
        scripts:
            [StaticJavaScriptDependency]
    ) {
        self.stylesheet =
            stylesheet

        self.scripts =
            scripts
    }
}
