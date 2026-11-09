import CSS
import HTML
import JS

/// A projected semantic page after its document representation has been built.
///
/// The authoritative HTML value remains `HTMLDocument`. CSS and JavaScript
/// dependency identity also remain structurally resolved. No textual or
/// filesystem materialization occurs here.
public struct RenderedDocument<
    Page:
        PageGraphNode
>:
    Sendable
{
    public typealias Identifier =
        Page.PageIdentifier

    public let projectedPage:
        PageProjection<Page>

    public let document:
        HTMLDocument

    public let dependencies:
        RenderDependencies

    public init(
        projectedPage:
            PageProjection<Page>,
        document:
            HTMLDocument,
        dependencies:
            RenderDependencies
    ) {
        self.projectedPage =
            projectedPage

        self.document =
            document

        self.dependencies =
            dependencies
    }

    public var identifier:
        Page.PageIdentifier
    {
        projectedPage
            .identifier
    }

    public var route:
        SiteRoute
    {
        projectedPage
            .siteRoute
    }

    public var styles:
        ResolvedCSSContributions
    {
        dependencies
            .styles
    }

    public var scripts:
        ResolvedJSContributions
    {
        dependencies
            .scripts
    }
}
