import HTML
import CSS
import JS
import Primitives

public extension PageTarget {
    func bundle(in environment: BuildEnvironment) throws -> RenderBundle {
        RenderBundle(
            try document(in: environment).render_contribution()
        )
    }

    /// Legacy environment-independent adapter.
    func bundle() throws -> RenderBundle {
        RenderBundle(
            try html().render_contribution()
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
