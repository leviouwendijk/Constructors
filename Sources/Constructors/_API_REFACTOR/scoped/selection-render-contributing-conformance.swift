import CSS
import JS
import DSL

extension CSSBundledSheet: SelectionRenderContributing {
    public func selected_render_contribution(
        for selection: ScopeSelection
    ) -> RenderContribution {
        guard selection.includes(scope: scope) else {
            return .empty
        }

        return RenderContribution(
            stylesheets: [sheet]
        )
    }
}

extension JSBundledScript: SelectionRenderContributing {
    public func selected_render_contribution(
        for selection: ScopeSelection
    ) -> RenderContribution {
        guard selection.includes(scope: scope) else {
            return .empty
        }

        return RenderContribution(
            scripts: [script]
        )
    }
}
