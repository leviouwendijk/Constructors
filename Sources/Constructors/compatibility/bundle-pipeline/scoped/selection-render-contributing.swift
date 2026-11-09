import DSL

public protocol SelectionRenderContributing: Sendable {
    func selected_render_contribution(
        for selection: ScopeSelection
    ) -> RenderContribution
}
