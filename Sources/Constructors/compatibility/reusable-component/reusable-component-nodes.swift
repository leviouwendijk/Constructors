import CSS
import HTML
import JS

public struct ReusableComponentNodes: Sendable {
    public let head: HTMLFragment
    public let body: HTMLFragment
    public let stylesheets: [CSSStyleSheet]
    public let scripts: [JSScript]

    public init(
        head: HTMLFragment = [],
        body: HTMLFragment = [],
        stylesheets: [CSSStyleSheet] = [],
        scripts: [JSScript] = []
    ) {
        self.head = head
        self.body = body
        self.stylesheets = stylesheets
        self.scripts = scripts
    }

    public func render_contribution() -> RenderContribution {
        RenderContribution(
            head: head,
            body: body,
            stylesheets: stylesheets,
            scripts: scripts
        )
    }

    public static func body(
        _ body: HTMLFragment,
        stylesheets: [CSSStyleSheet] = [],
        scripts: [JSScript] = []
    ) -> Self {
        Self(
            body: body,
            stylesheets: stylesheets,
            scripts: scripts
        )
    }

    public static func head(
        _ head: HTMLFragment,
        stylesheets: [CSSStyleSheet] = [],
        scripts: [JSScript] = []
    ) -> Self {
        Self(
            head: head,
            stylesheets: stylesheets,
            scripts: scripts
        )
    }
}
