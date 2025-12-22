import HTML
import Path

public struct SiteDynamicLink<S: SiteObject> {
    public init() {}

    public func css_default() -> [any HTMLNode] {
        return build(appending: "default")
    }

    public func css_base() -> [any HTMLNode] {
        return build(appending: "base")
    }

    public func css_sub() -> [any HTMLNode] {
        return build(appending: "sub")
    }

    public func build(
        root: GenericPath = .init("assets", "css"),
        appending name: String = "dynamic",
        suffix: String = "-minified",
        extension: String = ".css",
        includeVersion: Bool = true,
        asRootPath: Bool = true
    ) -> [any HTMLNode] {
        var n = name
        n.append(suffix)
        n.append(`extension`)

        if includeVersion {
            n.append("?v=\(S.version)")
        }

        var path = root
        path.appendingSegments(n)
        let finalpath = path.rendered(asRootPath: asRootPath)
        return [
            // SharedRoot.build(), // should be replaced in all callers to just be inserted manually in heads
            HTML.link(
                .stylesheet(
                    href: finalpath
                )
            )
        ]
    }
}
