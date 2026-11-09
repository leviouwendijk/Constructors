import DSL

public extension RenderContributing {
    func bundle(
        selecting selection: ScopeSelection,
        assets: [any SelectionRenderContributing] = []
    ) -> RenderBundle {
        RenderBundle.collect(
            selecting: selection,
            from: self,
            assets: assets
        )
    }

    func bundle<Scope: ScopeIdentifying>(
        scoped scope: Scope,
        assets: [any SelectionRenderContributing] = []
    ) -> RenderBundle {
        RenderBundle.collect(
            selecting: .scoped(scope.scope),
            from: self,
            assets: assets
        )
    }

    func bundle(
        unscopedWith assets: [any SelectionRenderContributing] = []
    ) -> RenderBundle {
        RenderBundle.collect(
            selecting: .unscoped,
            from: self,
            assets: assets
        )
    }
}
