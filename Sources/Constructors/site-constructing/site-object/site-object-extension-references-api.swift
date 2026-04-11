import Path

public extension SiteObject {
    static func refer<T: TargetIdentifying>(
        to target: T,
        absolute: Bool = false,
        relativity: PathRelativity = .root
    ) -> String {
        let reference_path = target.target().output

        if absolute {
            return Self.site.compose_address(
                appending: reference_path
            )
        }

        return reference_path.render(as: relativity)
    }
}

public extension SiteObject {
    static func refer(
        path: StandardPath,
        absolute: Bool = false,
        relativity: PathRelativity = .root
    ) -> String {
        if absolute {
            return Self.site.compose_address(
                appending: path
            )
        }

        return path.render(as: relativity)
    }
}

public extension SiteObject {
    static func refer(
        page: Page,
        absolute: Bool = false,
        relativity: PathRelativity = .root
    ) -> String {
        self.refer(
            to: page,
            absolute: absolute,
            relativity: relativity
        )
    }

    static func refer(
        stylesheet: Stylesheet,
        absolute: Bool = false,
        relativity: PathRelativity = .root
    ) -> String {
        self.refer(
            to: stylesheet,
            absolute: absolute,
            relativity: relativity
        )
    }

    static func refer(
        snippet: Snippet,
        absolute: Bool = false,
        relativity: PathRelativity = .root
    ) -> String {
        self.refer(
            to: snippet,
            absolute: absolute,
            relativity: relativity
        )
    }
}

// refactor SitePageDefinition
public extension SiteObject {
    static func refer(
        document: SiteDocumentDefinition,
        absolute: Bool = false,
        relativity: PathRelativity = .root
    ) -> String {
        let reference_path = document.output

        if absolute {
            return Self.site.compose_address(
                appending: reference_path
            )
        }

        return reference_path.render(as: relativity)
    }
}

public extension SiteObject {
    @available(*, deprecated, message: "use relativity: .root or .relative")
    static func refer<T: TargetIdentifying>(
        to target: T,
        absolute: Bool = false,
        asRootPath: Bool
    ) -> String {
        refer(
            to: target,
            absolute: absolute,
            relativity: asRootPath ? .root : .relative
        )
    }

    @available(*, deprecated, message: "use relativity: .root or .relative")
    static func refer(
        path: StandardPath,
        absolute: Bool = false,
        asRootPath: Bool
    ) -> String {
        refer(
            path: path,
            absolute: absolute,
            relativity: asRootPath ? .root : .relative
        )
    }

    @available(*, deprecated, message: "use relativity: .root or .relative")
    static func refer(
        page: Page,
        absolute: Bool = false,
        asRootPath: Bool
    ) -> String {
        refer(
            page: page,
            absolute: absolute,
            relativity: asRootPath ? .root : .relative
        )
    }

    @available(*, deprecated, message: "use relativity: .root or .relative")
    static func refer(
        stylesheet: Stylesheet,
        absolute: Bool = false,
        asRootPath: Bool
    ) -> String {
        refer(
            stylesheet: stylesheet,
            absolute: absolute,
            relativity: asRootPath ? .root : .relative
        )
    }

    @available(*, deprecated, message: "use relativity: .root or .relative")
    static func refer(
        snippet: Snippet,
        absolute: Bool = false,
        asRootPath: Bool
    ) -> String {
        refer(
            snippet: snippet,
            absolute: absolute,
            relativity: asRootPath ? .root : .relative
        )
    }

    @available(*, deprecated, message: "use relativity: .root or .relative")
    static func refer(
        document: SiteDocumentDefinition,
        absolute: Bool = false,
        asRootPath: Bool
    ) -> String {
        refer(
            document: document,
            absolute: absolute,
            relativity: asRootPath ? .root : .relative
        )
    }
}

// previous:

// public extension SiteObject {
//     // generic
//     static func refer<T: TargetIdentifying>(
//         to target: T,
//         absolute: Bool = false,
//         asRootPath: Bool = true
//     ) -> String {
//         let reference_path = target.target().output

//         if absolute {
//             return Self.site.compose_address(appending: reference_path)
//         }
//         return reference_path.rendered(asRootPath: asRootPath)
//     }

//     // // existential
//     // static func refer(
//     //     to target: (any TargetIdentifying),
//     //     absolute: Bool = false,
//     //     asRootPath: Bool = true
//     // ) -> String {
//     //     if absolute {
//     //         return Self.site.compose_address(appending: target.target().output)
//     //     }
//     //     return target.target().output.rendered(asRootPath: asRootPath)
//     // }
// }

// // generic StandardPath appending
// public extension SiteObject {
//     static func refer(
//         path: StandardPath,
//         absolute: Bool = false,
//         asRootPath: Bool = true
//     ) -> String {
//         if absolute {
//             return Self.site.compose_address(appending: path)
//         }
//         return path.rendered(asRootPath: asRootPath)
//     }
// }

// // typed overloads
// public extension SiteObject {
//     static func refer(
//         page: Page,
//         absolute: Bool = false,
//         asRootPath: Bool = true
//     ) -> String {
//         self.refer(
//             to: page,
//             absolute: absolute,
//             asRootPath: asRootPath
//         )
//     }

//     static func refer(
//         stylesheet: Stylesheet,
//         absolute: Bool = false,
//         asRootPath: Bool = true
//     ) -> String {
//         self.refer(
//             to: stylesheet,
//             absolute: absolute,
//             asRootPath: asRootPath
//         )
//     }

//     static func refer(
//         snippet: Snippet,
//         absolute: Bool = false,
//         asRootPath: Bool = true
//     ) -> String {
//         self.refer(
//             to: snippet,
//             absolute: absolute,
//             asRootPath: asRootPath
//         )
//     }
// }

