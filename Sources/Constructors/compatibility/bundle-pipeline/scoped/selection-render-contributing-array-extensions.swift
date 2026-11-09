import DSL

public extension Array where Element: SelectionRenderContributing {
    func contribution(
        selecting selection: ScopeSelection
    ) -> RenderContribution {
        reduce(.empty) { partial, element in
            partial.merging(
                element.selected_render_contribution(
                    for: selection
                )
            )
        }
    }

    func bundle(
        selecting selection: ScopeSelection
    ) -> RenderBundle {
        RenderBundle(
            contribution(selecting: selection)
        )
    }
}

public extension Array where Element == any SelectionRenderContributing {
    func contribution(
        selecting selection: ScopeSelection
    ) -> RenderContribution {
        reduce(.empty) { partial, element in
            partial.merging(
                element.selected_render_contribution(
                    for: selection
                )
            )
        }
    }

    func bundle(
        selecting selection: ScopeSelection
    ) -> RenderBundle {
        RenderBundle(
            contribution(selecting: selection)
        )
    }
}
