public protocol RenderContributing: Sendable {
    func render_contribution() -> RenderContribution
}
