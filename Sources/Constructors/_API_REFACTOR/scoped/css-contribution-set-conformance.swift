import CSS
import DSL

extension CSSContributionSet: SelectionRenderContributing {
    public func selected_render_contribution(
        for selection: ScopeSelection
    ) -> RenderContribution {
        let sheet = collected(selection)

        guard
            !sheet.rules.isEmpty ||
            !sheet.media.isEmpty ||
            !sheet.keyframes.isEmpty
        else {
            return .empty
        }

        return RenderContribution(
            stylesheets: [sheet]
        )
    }
}

extension CSSContributionSet: RenderContributing {
    public func render_contribution() -> RenderContribution {
        RenderContribution(
            stylesheets: [sheet]
        )
    }
}
