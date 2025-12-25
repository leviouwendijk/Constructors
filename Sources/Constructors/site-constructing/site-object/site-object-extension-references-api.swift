import Path

public extension SiteObject {
    // generic
    static func refer<T: TargetIdentifying>(
        to target: T,
        absolute: Bool = false,
        asRootPath: Bool = true
    ) -> String {
        let reference_path = target.target().output

        if absolute {
            return Self.site.compose_address(appending: reference_path)
        }
        return reference_path.rendered(asRootPath: asRootPath)
    }

    // // existential
    // static func refer(
    //     to target: (any TargetIdentifying),
    //     absolute: Bool = false,
    //     asRootPath: Bool = true
    // ) -> String {
    //     if absolute {
    //         return Self.site.compose_address(appending: target.target().output)
    //     }
    //     return target.target().output.rendered(asRootPath: asRootPath)
    // }
}

// typed overloads
public extension SiteObject {
    static func refer(
        page: Page,
        absolute: Bool = false,
        asRootPath: Bool = true
    ) -> String {
        self.refer(
            to: page,
            absolute: absolute,
            asRootPath: asRootPath
        )
    }

    static func refer(
        stylesheet: Stylesheet,
        absolute: Bool = false,
        asRootPath: Bool = true
    ) -> String {
        self.refer(
            to: stylesheet,
            absolute: absolute,
            asRootPath: asRootPath
        )
    }

    static func refer(
        snippet: Snippet,
        absolute: Bool = false,
        asRootPath: Bool = true
    ) -> String {
        self.refer(
            to: snippet,
            absolute: absolute,
            asRootPath: asRootPath
        )
    }
}
