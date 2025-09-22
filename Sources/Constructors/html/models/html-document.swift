import Foundation

public struct HTMLDocument {
    public var children: [any HTMLNode]
    public init(children: [any HTMLNode]) { self.children = children }

    public func render(pretty: Bool = true, indentStep: Int = 2) -> String {
        let body = children.map { $0.render(pretty: pretty, indent: 0, indentStep: indentStep) }.joined()
        return "<!DOCTYPE html>\n" + body
    }

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
                    HTML.meta(["charset": "UTF-8"])
                    if let title = title { HTML.title(title) }
                    for href in stylesheets { HTML.linkStylesheet(href: href) }
                    if let css = inlineStyle { HTML.style(css) }
                }
                HTML.body {
                    body()
                }
            }
        }
    }
}
