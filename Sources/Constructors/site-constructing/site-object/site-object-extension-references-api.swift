import Path

public extension SiteObject {
    static func refer(
        path: StandardPath,
        style: SiteReferenceStyle = .automatic
    ) -> String {
        resolve_reference(
            path: path,
            destinationSite: Self.site,
            style: style
        )
    }

    static func refer(
        path: StandardPath,
        on destinationSite: any SiteResolvable,
        style: SiteReferenceStyle = .automatic
    ) -> String {
        resolve_reference(
            path: path,
            destinationSite: destinationSite,
            style: style
        )
    }

    static func refer<Destination: SiteObject>(
        path: StandardPath,
        on destination: Destination.Type,
        style: SiteReferenceStyle = .automatic
    ) -> String {
        refer(
            path: path,
            on: destination.site,
            style: style
        )
    }

    static func refer<T: TargetIdentifying>(
        to target: T,
        on destinationSite: any SiteResolvable,
        style: SiteReferenceStyle = .automatic
    ) -> String {
        resolve_reference(
            path: target.target().output,
            destinationSite: destinationSite,
            style: style
        )
    }

    static func refer<Destination: SiteObject, T: TargetIdentifying>(
        to target: T,
        on destination: Destination.Type,
        style: SiteReferenceStyle = .automatic
    ) -> String {
        refer(
            to: target,
            on: destination.site,
            style: style
        )
    }
}

public extension SiteObject {
    static func refer(
        page: Page,
        style: SiteReferenceStyle = .automatic
    ) -> String {
        resolve_reference(
            path: page.target().output,
            destinationSite: Self.site,
            style: style
        )
    }

    static func refer(
        stylesheet: Stylesheet,
        style: SiteReferenceStyle = .automatic
    ) -> String {
        resolve_reference(
            path: stylesheet.target().output,
            destinationSite: Self.site,
            style: style
        )
    }

    static func refer(
        snippet: Snippet,
        style: SiteReferenceStyle = .automatic
    ) -> String {
        resolve_reference(
            path: snippet.target().output,
            destinationSite: Self.site,
            style: style
        )
    }

    static func refer(
        document: SiteDocumentDefinition,
        style: SiteReferenceStyle = .automatic
    ) -> String {
        resolve_reference(
            path: document.output,
            destinationSite: Self.site,
            style: style
        )
    }

    static func refer(
        document: SiteDocumentDefinition,
        on destinationSite: any SiteResolvable,
        style: SiteReferenceStyle = .automatic
    ) -> String {
        resolve_reference(
            path: document.output,
            destinationSite: destinationSite,
            style: style
        )
    }
}

private extension SiteObject {
    static func resolve_reference(
        path: StandardPath,
        destinationSite: any SiteResolvable,
        style: SiteReferenceStyle
    ) -> String {
        resolve_site_reference(
            sourceSite: Self.site,
            destinationSite: destinationSite,
            path: path,
            style: style
        )
    }
}

// public extension SiteObject {
//     static func refer<T: TargetIdentifying>(
//         to target: T,
//         absolute: Bool = false,
//         relativity: PathRelativity = .root
//     ) -> String {
//         let reference_path = target.target().output

//         if absolute {
//             return Self.site.compose_address(
//                 appending: reference_path
//             )
//         }

//         return reference_path.render(as: relativity)
//     }
// }

// public extension SiteObject {
//     static func refer(
//         path: StandardPath,
//         absolute: Bool = false,
//         relativity: PathRelativity = .root
//     ) -> String {
//         if absolute {
//             return Self.site.compose_address(
//                 appending: path
//             )
//         }

//         return path.render(as: relativity)
//     }
// }

// public extension SiteObject {
//     static func refer(
//         page: Page,
//         absolute: Bool = false,
//         relativity: PathRelativity = .root
//     ) -> String {
//         self.refer(
//             to: page,
//             absolute: absolute,
//             relativity: relativity
//         )
//     }

//     static func refer(
//         stylesheet: Stylesheet,
//         absolute: Bool = false,
//         relativity: PathRelativity = .root
//     ) -> String {
//         self.refer(
//             to: stylesheet,
//             absolute: absolute,
//             relativity: relativity
//         )
//     }

//     static func refer(
//         snippet: Snippet,
//         absolute: Bool = false,
//         relativity: PathRelativity = .root
//     ) -> String {
//         self.refer(
//             to: snippet,
//             absolute: absolute,
//             relativity: relativity
//         )
//     }
// }

// // refactor SitePageDefinition
// public extension SiteObject {
//     static func refer(
//         document: SiteDocumentDefinition,
//         absolute: Bool = false,
//         relativity: PathRelativity = .root
//     ) -> String {
//         let reference_path = document.output

//         if absolute {
//             return Self.site.compose_address(
//                 appending: reference_path
//             )
//         }

//         return reference_path.render(as: relativity)
//     }
// }

// public extension SiteObject {
//     @available(*, deprecated, message: "use relativity: .root or .relative")
//     static func refer<T: TargetIdentifying>(
//         to target: T,
//         absolute: Bool = false,
//         asRootPath: Bool
//     ) -> String {
//         refer(
//             to: target,
//             absolute: absolute,
//             relativity: asRootPath ? .root : .relative
//         )
//     }

//     @available(*, deprecated, message: "use relativity: .root or .relative")
//     static func refer(
//         path: StandardPath,
//         absolute: Bool = false,
//         asRootPath: Bool
//     ) -> String {
//         refer(
//             path: path,
//             absolute: absolute,
//             relativity: asRootPath ? .root : .relative
//         )
//     }

//     @available(*, deprecated, message: "use relativity: .root or .relative")
//     static func refer(
//         page: Page,
//         absolute: Bool = false,
//         asRootPath: Bool
//     ) -> String {
//         refer(
//             page: page,
//             absolute: absolute,
//             relativity: asRootPath ? .root : .relative
//         )
//     }

//     @available(*, deprecated, message: "use relativity: .root or .relative")
//     static func refer(
//         stylesheet: Stylesheet,
//         absolute: Bool = false,
//         asRootPath: Bool
//     ) -> String {
//         refer(
//             stylesheet: stylesheet,
//             absolute: absolute,
//             relativity: asRootPath ? .root : .relative
//         )
//     }

//     @available(*, deprecated, message: "use relativity: .root or .relative")
//     static func refer(
//         snippet: Snippet,
//         absolute: Bool = false,
//         asRootPath: Bool
//     ) -> String {
//         refer(
//             snippet: snippet,
//             absolute: absolute,
//             relativity: asRootPath ? .root : .relative
//         )
//     }

//     @available(*, deprecated, message: "use relativity: .root or .relative")
//     static func refer(
//         document: SiteDocumentDefinition,
//         absolute: Bool = false,
//         asRootPath: Bool
//     ) -> String {
//         refer(
//             document: document,
//             absolute: absolute,
//             relativity: asRootPath ? .root : .relative
//         )
//     }
// }

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

