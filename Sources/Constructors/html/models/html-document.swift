import Foundation

public struct HTMLDocument: Sendable {
    public var children: [any HTMLNode]
    public init(children: [any HTMLNode]) { self.children = children }

    // @available(*, message: "Deprecated, instead of 'indentStep', use 'options: HTMLRenderOptions()'")
    // public func render(pretty: Bool = true, indentStep: Int = 4) -> String {
    //     let body = children.map { $0.render(pretty: pretty, indent: 0, indentStep: indentStep) }.joined()
    //     return "<!DOCTYPE html>\n" + body
    // }

    // @available(*, message: "Deprecated, use 'options: HTMLRenderOptions()'")
    // public func render(options: HTMLRenderOptions = .init(), pretty: Bool = true) -> String {
    //     let body = children.map {
    //         $0.render(pretty: pretty, indent: 0, indentStep: options.indentStep)
    //     }.joined()

    //     var out = "<!DOCTYPE html>\n" + body
    //     if options.ensureTrailingNewline, !out.hasSuffix("\n") { out.append("\n") }
    //     return out
    // }

    public func render(options: HTMLRenderOptions = .init()) -> String {
        let body = children.map { $0.render(options: options, indent: 0) }.joined()
        var out = "<!DOCTYPE html>\n" + body
        if options.ensureTrailingNewline, !out.hasSuffix("\n") { out.append("\n") }
        return out
    }

    // @available(*, message: "deprecated")
    // public static func basic(
    //     lang: String? = nil,
    //     title: String? = nil,
    //     stylesheets: [String] = [],
    //     inlineStyle: String? = nil,
    //     @HTMLBuilder body: () -> [any HTMLNode]
    // ) -> HTMLDocument {
    //     HTML.document {
    //         HTML.html(lang.map { ["lang": $0] } ?? HTMLAttribute()) {
    //             HTML.head {
    //                 HTML.meta(["charset": "UTF-8"])
    //                 if let title = title { HTML.title(title) }
    //                 for href in stylesheets { HTML.linkStylesheet(href: href) }
    //                 if let css = inlineStyle { HTML.style(css) }
    //             }
    //             HTML.body {
    //                 body()
    //             }
    //         }
    //     }
    // }

    /// Minimal convenience page builder (kept small on purpose).
    /// Uses MetaSpec/LinkSpec instead of legacy helpers.
    public static func basic(
        lang: String? = nil,
        title: String? = nil,
        stylesheets: [String] = [],
        inlineStyle: String? = nil,
        @HTMLBuilder body: () -> [any HTMLNode]
    ) -> HTMLDocument {
        HTML.document {
            HTML.html(lang.map { ["lang": $0] } ?? HTMLAttribute()) {
                HTML.head {
                    // <meta charset="UTF-8">
                    HTML.meta(.charset())

                    if let title {
                        HTML.title(title)
                    }

                    // <link rel="stylesheet" ...> (in author order)
                    for href in stylesheets {
                        HTML.link(.stylesheet(href: href))
                    }

                    // Inline <style> … </style>
                    if let css = inlineStyle {
                        HTML.style(css)
                    }
                }
                HTML.body {
                    body()
                }
            }
        }
    }
}
