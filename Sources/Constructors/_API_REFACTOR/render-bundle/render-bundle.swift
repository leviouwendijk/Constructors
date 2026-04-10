import CSS
import HTML
import JS

public struct RenderBundle: Sendable {
    public let contribution: RenderContribution

    public init(
        _ contribution: RenderContribution = .empty
    ) {
        self.contribution = contribution
    }

    public static func collect(
        _ sources: any RenderContributing...
    ) -> RenderBundle {
        collect(sources)
    }

    public static func collect(
        _ sources: [any RenderContributing]
    ) -> RenderBundle {
        let merged = sources.reduce(
            RenderContribution.empty
        ) { partial, source in
            partial.merging(
                source.render_contribution()
            )
        }

        return RenderBundle(merged)
    }

    public var head: HTMLFragment {
        contribution.head
    }

    public var body: HTMLFragment {
        contribution.body
    }

    public var stylesheets: CSSBundle {
        contribution.stylesheets
    }

    public var scripts: JSBundle {
        contribution.scripts
    }

    internal var htmlCollectionsForCSS: [HTMLFragment] {
        [
            head,
            body
        ].filter { !$0.isEmpty }
    }

    public func merging(
        _ other: RenderBundle
    ) -> RenderBundle {
        RenderBundle(
            self.contribution.merging(
                other.contribution
            )
        )
    }
}

public extension RenderBundle {
    var document: ExportAPI.DocumentAPI {
        export.document
    }

    var fragment: ExportAPI.FragmentAPI {
        export.fragment
    }

    // Compatibility aliases
    var html: ExportAPI.DocumentAPI.HTMLAPI {
        export.html
    }

    var css: ExportAPI.DocumentAPI.CSSAPI {
        export.css
    }

    var js: ExportAPI.DocumentAPI.JSAPI {
        export.js
    }
}

public extension RenderBundle {
    static func collect(
        _ components: any ReusableComponent...
    ) -> RenderBundle {
        components.bundle()
    }

    static func collect(
        _ components: [any ReusableComponent]
    ) -> RenderBundle {
        components.bundle()
    }
}
