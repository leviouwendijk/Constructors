import HTML
import CSS
import JS
import DSL

public extension RenderBundle {
    static func collect(
        selecting selection: ScopeSelection,
        from source: any RenderContributing,
        assets: [any SelectionRenderContributing] = []
    ) -> RenderBundle {
        let base = source.render_contribution()

        let selectedHead = HTMLScopeSelector.select(
            selection,
            from: base.head
        )

        let selectedBody = HTMLScopeSelector.select(
            selection,
            from: base.body
        )

        let selectedHTML = RenderContribution(
            head: selectedHead,
            body: selectedBody,
            stylesheet_bundle: CSSBundle(),
            script_bundle: JSBundle()
        )

        let selectedAssets = assets.reduce(
            RenderContribution.empty
        ) { partial, asset in
            partial.merging(
                asset.selected_render_contribution(
                    for: selection
                )
            )
        }

        return RenderBundle(
            selectedHTML.merging(
                selectedAssets
            )
        )
    }

    static func collect<Scope: ScopeIdentifying>(
        scoped scope: Scope,
        from source: any RenderContributing,
        assets: [any SelectionRenderContributing] = []
    ) -> RenderBundle {
        collect(
            selecting: .scoped(scope.scope),
            from: source,
            assets: assets
        )
    }

    static func collect(
        unscopedFrom source: any RenderContributing,
        assets: [any SelectionRenderContributing] = []
    ) -> RenderBundle {
        collect(
            selecting: .unscoped,
            from: source,
            assets: assets
        )
    }
}
