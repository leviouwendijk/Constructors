import CSS
import HTML
import JS

extension RenderContribution: RenderContributing {
    public func render_contribution() -> RenderContribution {
        self
    }
}

extension RenderBundle: RenderContributing {
    public func render_contribution() -> RenderContribution {
        contribution
    }
}

extension HTMLDocument: RenderContributing {
    public func render_contribution() -> RenderContribution {
        RenderContribution(
            head: self.head,
            body: self.body,
            stylesheet_bundle: CSSBundle(),
            script_bundle: JSBundle()
        )
    }
}

extension HTMLFragment: RenderContributing {
    public func render_contribution() -> RenderContribution {
        RenderContribution(
            body: self,
            stylesheet_bundle: CSSBundle(),
            script_bundle: JSBundle()
        )
    }
}

extension CSSStyleSheet: RenderContributing {
    public func render_contribution() -> RenderContribution {
        RenderContribution(
            stylesheets: [self]
        )
    }
}

extension JSScript: RenderContributing {
    public func render_contribution() -> RenderContribution {
        RenderContribution(
            scripts: [self]
        )
    }
}

public extension Array where Element: RenderContributing {
    func contribution() -> RenderContribution {
        reduce(.empty) { partial, element in
            partial.merging(
                element.render_contribution()
            )
        }
    }

    func bundle() -> RenderBundle {
        RenderBundle(
            contribution()
        )
    }
}

public extension Array where Element == any RenderContributing {
    func contribution() -> RenderContribution {
        reduce(.empty) { partial, element in
            partial.merging(
                element.render_contribution()
            )
        }
    }

    func bundle() -> RenderBundle {
        RenderBundle(
            contribution()
        )
    }
}
