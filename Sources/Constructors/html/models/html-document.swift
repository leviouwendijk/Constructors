import Foundation
import plate

public struct HTMLDocument: Sendable {
    public var children: [any HTMLNode]

    public init(
        children: [any HTMLNode]
    ) { 
        self.children = children 
    }

    public func render(options: HTMLRenderOptions = .init()) -> String {
        var out = HTMLDoctype(.html5).render(options: options)

        let content = children
            .map { $0.render(options: options, indent: 0) }
            .joined()

        out += content

        if options.ensureTrailingNewline, !out.hasSuffix("\n") {
            out.append("\n")
        }
        return out
    }

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

extension HTMLDocument {
    public enum RenderDefault {
        case pretty
        case minified
    }

    public func render(
        default: RenderDefault = .pretty,
        indentStep: Int? = nil,
        attributeOrder: HTMLAttributeOrder? = nil,
        ensureTrailingNewline: Bool? = nil,
        environment: BuildEnvironment? = nil,
        onGate: (@Sendable (GateEvent) -> Void)? = nil
    ) -> String {
        var opts = HTMLRenderOptions()

        switch `default` {
        case .pretty:
            opts = HTMLRenderOptions.Defaults.pretty()
        case .minified:
            opts = HTMLRenderOptions.Defaults.minified()
        }

        indentStep.ifNotNil { value in 
            opts.indentStep = value 
        }

        attributeOrder.ifNotNil { value in 
            opts.attributeOrder = value
        }

        ensureTrailingNewline.ifNotNil { value in 
            opts.ensureTrailingNewline = value
        }
        environment.ifNotNil { value in
            opts.environment = value
        }

        opts.onGate = onGate

        return render(options: opts)
    }
}
