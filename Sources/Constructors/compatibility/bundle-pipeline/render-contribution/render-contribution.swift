import CSS
import HTML
import JS

public struct RenderContribution: Sendable {
    public let head: HTMLFragment
    public let body: HTMLFragment
    public let stylesheets: CSSBundle
    public let scripts: JSBundle

    public init(
        head: HTMLFragment = [],
        body: HTMLFragment = [],
        stylesheet_bundle: CSSBundle = CSSBundle(),
        script_bundle: JSBundle = JSBundle()
    ) {
        self.head = head
        self.body = body
        self.stylesheets = stylesheet_bundle
        self.scripts = script_bundle
    }

    public init(
        head: HTMLFragment = [],
        body: HTMLFragment = [],
        stylesheets: [CSSStyleSheet] = [],
        scripts: [JSScript] = []
    ) {
        self.init(
            head: head,
            body: body,
            stylesheet_bundle: CSSBundle(stylesheets),
            script_bundle: JSBundle(scripts)
        )
    }

    public static let empty = RenderContribution(
        stylesheet_bundle: CSSBundle(),
        script_bundle: JSBundle()
    )

    public func merging(
        _ other: RenderContribution
    ) -> RenderContribution {
        RenderContribution(
            head: self.head + other.head,
            body: self.body + other.body,
            stylesheet_bundle: self.stylesheets.merged(with: other.stylesheets),
            script_bundle: self.scripts.merged(with: other.scripts)
        )
    }
}
