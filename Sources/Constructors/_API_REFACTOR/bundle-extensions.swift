import HTML
import CSS
import JS

public extension PageTarget {
    func bundle() -> RenderBundle {
        RenderBundle(
            html().render_contribution()
        )
    }
}

public extension StylesheetTarget {
    func bundle() -> RenderBundle {
        RenderBundle(
            RenderContribution(
                stylesheets: [sheet]
            )
        )
    }
}

public extension SnippetTargets {
    func bundle() -> RenderBundle {
        RenderBundle(
            RenderContribution(
                body: html,
                stylesheets: stylesheets,
                scripts: javascript
            )
        )
    }
}
