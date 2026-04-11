import CSS
import HTML
import JS

public protocol ReusableComponent: RenderContributing, Sendable {
    typealias Nodes = ReusableComponentNodes

    var nodes: Nodes { get }
}

public extension ReusableComponent {
    func render_contribution() -> RenderContribution {
        nodes.render_contribution()
    }

    func bundle() -> RenderBundle {
        RenderBundle(
            render_contribution()
        )
    }
}

public extension Array where Element: ReusableComponent {
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

public extension Array where Element == any ReusableComponent {
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

// 2nd

// public protocol ReusableComponent: RenderContributing, Sendable {
//     func head() -> HTMLFragment
//     func body() -> HTMLFragment

//     func styles() -> [CSSStyleSheet]
//     func javascript() -> [JSScript]
// }

// extension ReusableComponent {
//     public func head() -> HTMLFragment { [] }
//     public func body() -> HTMLFragment { [] }
//     public func styles() -> [CSSStyleSheet] { [] }
//     public func javascript() -> [JSScript] { [] }
// }

// public extension Array where Element: ReusableComponent {
//     func gathered_head() -> HTMLFragment {
//         flatMap { $0.head() }
//     }

//     func gathered_body() -> HTMLFragment {
//         flatMap { $0.body() }
//     }

//     func gathered_styles() -> [CSSStyleSheet] {
//         flatMap { $0.styles() }
//     }

//     func gathered_javascript() -> [JSScript] {
//         flatMap { $0.javascript() }
//     }

//     // func artifact() -> RenderArtifact {
//     //     RenderArtifact(
//     //         head: gathered_head(),
//     //         html: gathered_body(),
//     //         scripts: gathered_javascript(),
//     //         stylesheets: gathered_styles()
//     //     )
//     // }

//     func css_bundle() -> CSSBundle {
//         CSSBundle(gathered_styles())
//     }
// }

// public extension Array where Element == any ReusableComponent {
//     func gathered_head() -> HTMLFragment {
//         flatMap { $0.head() }
//     }

//     func gathered_body() -> HTMLFragment {
//         flatMap { $0.body() }
//     }

//     func gathered_styles() -> [CSSStyleSheet] {
//         flatMap { $0.styles() }
//     }

//     func gathered_javascript() -> [JSScript] {
//         flatMap { $0.javascript() }
//     }

//     // func artifact() -> RenderArtifact {
//     //     RenderArtifact(
//     //         head: gathered_head(),
//     //         html: gathered_body(),
//     //         scripts: gathered_javascript(),
//     //         stylesheets: gathered_styles()
//     //     )
//     // }

//     func css_bundle() -> CSSBundle {
//         CSSBundle(gathered_styles())
//     }
// }

// ----

// 1st

// import CSS
// import HTML
// import JS

// public protocol ReusableComponent: Sendable {
//     // func html() -> HTMLFragment
//     func head() -> HTMLFragment
//     func body() -> HTMLFragment

//     func styles() -> [CSSStyleSheet]
//     func javascript() -> [JSSource]
// }

// // public extension Array where Element == any ReusableComponent {
// //     func gathered_styles() -> [CSSStyleSheet] {
// //         var out: [CSSStyleSheet] = []
// //         for c in self {
// //             out.append(contentsOf: c.styles())
// //         }
// //         return out
// //     }
// // }

// extension ReusableComponent {
//     public func head() -> HTMLFragment { [] }
//     public func body() -> HTMLFragment { [] }
//     public func styles() -> [CSSStyleSheet] { [] }
//     public func javascript() -> [JSSource] { [] }
// }

// public extension Array where Element: ReusableComponent {
//     func gathered_head() -> HTMLFragment {
//         flatMap { $0.head() }
//     }

//     func gathered_body() -> HTMLFragment {
//         flatMap { $0.body() }
//     }

//     func gathered_styles() -> [CSSStyleSheet] {
//         flatMap { $0.styles() }
//     }

//     func gathered_javascript() -> [JSSource] {
//         flatMap { $0.javascript() }
//     }
// }

// public extension Array where Element == any ReusableComponent {
//     func gathered_head() -> HTMLFragment {
//         flatMap { $0.head() }
//     }

//     func gathered_body() -> HTMLFragment {
//         flatMap { $0.body() }
//     }

//     func gathered_styles() -> [CSSStyleSheet] {
//         flatMap { $0.styles() }
//     }

//     func gathered_javascript() -> [JSSource] {
//         flatMap { $0.javascript() }
//     }
// }

// public extension ReusableComponent {
//     // func artifact() -> RenderArtifact {
//     //     RenderArtifact(
//     //         html: html(),
//     //         stylesheets: styles()
//     //     )
//     // }

//     // func css_bundle() -> CSSBundle {
//     //     artifact().css
//     // }
// }

// // public extension Array where Element: ReusableComponent {
// //     func gathered_html() -> HTMLFragment {
// //         flatMap { $0.html() }
// //     }

// //     func gathered_styles() -> [CSSStyleSheet] {
// //         flatMap { $0.styles() }
// //     }

// //     func artifact() -> RenderArtifact {
// //         RenderArtifact(
// //             html: gathered_html(),
// //             stylesheets: gathered_styles()
// //         )
// //     }

// //     func css_bundle() -> CSSBundle {
// //         artifact().css
// //     }
// // }

// // public extension Array where Element == any ReusableComponent {
// //     func gathered_html() -> HTMLFragment {
// //         flatMap { $0.html() }
// //     }

// //     func gathered_styles() -> [CSSStyleSheet] {
// //         flatMap { $0.styles() }
// //     }

// //     func artifact() -> RenderArtifact {
// //         RenderArtifact(
// //             html: gathered_html(),
// //             stylesheets: gathered_styles()
// //         )
// //     }

// //     func css_bundle() -> CSSBundle {
// //         artifact().css
// //     }
// // }
