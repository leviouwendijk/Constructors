import Foundation

// doc
@inlinable
public func document(
    @HTMLBuilder _ body: () -> [any HTMLNode]
) -> HTMLDocument {
    HTML.document(body)
}

// base
@inlinable
public func html(
    _ attrs: HTMLAttribute = HTMLAttribute(),
    @HTMLBuilder _ content: () -> [any HTMLNode]
) -> any HTMLNode {
    HTML.html(attrs, content)
}

@inlinable
public func head(
    _ attrs: HTMLAttribute = HTMLAttribute(),
    @HTMLBuilder _ content: () -> [any HTMLNode]
) -> any HTMLNode {
    HTML.head(attrs, content)
}

@inlinable
public func body(
    _ attrs: HTMLAttribute = HTMLAttribute(),
    @HTMLBuilder _ content: () -> [any HTMLNode]
) -> any HTMLNode {
    HTML.body(attrs, content)
}

// head
@inlinable
public func meta(
    _ attrs: HTMLAttribute
) -> any HTMLNode {
    HTML.meta(attrs)
}

@inlinable
public func title(
    _ text: String
) -> any HTMLNode {
    HTML.title(text)
}

@inlinable
public func stylesheet(
    href: String
) -> any HTMLNode {
    HTML.stylesheet(href: href)
}

@inlinable
public func style(
    _ css: String
) -> any HTMLNode {
    HTML.style(css)
}

@inlinable
public func script(
    src: String,
    defer: Bool = false,
    `async`: Bool = false,
    type: String? = nil,
    integrity: String? = nil,
    crossorigin: String? = nil,
    nonce: String? = nil,
    _ extra: HTMLAttribute = HTMLAttribute()
) -> any HTMLNode {
    HTML.script(
        src: src,
        defer: `defer`,
        async: `async`,
        type: type,
        integrity: integrity,
        crossorigin: crossorigin,
        nonce: nonce,
        extra
    )
}

@inlinable
public func div(
    _ attrs: HTMLAttribute = HTMLAttribute(),
    @HTMLBuilder _ content: () -> [any HTMLNode]
) -> any HTMLNode {
    HTML.div(attrs, content)
}

@inlinable
public func span(
    _ attrs: HTMLAttribute = HTMLAttribute(),
    @HTMLBuilder _ content: () -> [any HTMLNode]
) -> any HTMLNode {
    HTML.span(attrs, content)
}

@inlinable
public func section(
    _ attrs: HTMLAttribute = HTMLAttribute(),
    @HTMLBuilder _ content: () -> [any HTMLNode]
) -> any HTMLNode {
    HTML.section(attrs, content)
}

@inlinable
public func header(
    _ attrs: HTMLAttribute = [:],
    @HTMLBuilder _ content: () -> [any HTMLNode]
) -> any HTMLNode {
    HTML.header(attrs, content)
}

@inlinable
public func nav(
    _ attrs: HTMLAttribute = [:],
    @HTMLBuilder _ content: () -> [any HTMLNode]
) -> any HTMLNode {
    HTML.nav(attrs, content)
}

@inlinable
public func main(
    _ attrs: HTMLAttribute = [:],
    @HTMLBuilder _ content: () -> [any HTMLNode]
) -> any HTMLNode {
    HTML.main(attrs, content)
}

@inlinable
public func article(
    _ attrs: HTMLAttribute = [:],
    @HTMLBuilder _ content: () -> [any HTMLNode]
) -> any HTMLNode {
    HTML.article(attrs, content)
}

@inlinable
public func footer(
    _ attrs: HTMLAttribute = [:],
    @HTMLBuilder _ content: () -> [any HTMLNode]
) -> any HTMLNode {
    HTML.footer(attrs, content)
}

@inlinable
public func p(
    _ attrs: HTMLAttribute = HTMLAttribute(),
    @HTMLBuilder _ content: () -> [any HTMLNode]
) -> any HTMLNode {
    HTML.p(attrs, content)
}

@inlinable
public func h1(
    _ attrs: HTMLAttribute = [:],
    @HTMLBuilder _ content: () -> [any HTMLNode]
) -> any HTMLNode {
    HTML.h1(attrs, content)
}

@inlinable
public func h2(
    _ attrs: HTMLAttribute = [:],
    @HTMLBuilder _ content: () -> [any HTMLNode]
) -> any HTMLNode {
    HTML.h2(attrs, content)
}

@inlinable
public func h3(
    _ attrs: HTMLAttribute = [:],
    @HTMLBuilder _ content: () -> [any HTMLNode]
) -> any HTMLNode {
    HTML.h3(attrs, content)
}

@inlinable
public func h4(
    _ attrs: HTMLAttribute = [:],
    @HTMLBuilder _ content: () -> [any HTMLNode]
) -> any HTMLNode {
    HTML.h4(attrs, content)
}

@inlinable
public func h5(
    _ attrs: HTMLAttribute = [:],
    @HTMLBuilder _ content: () -> [any HTMLNode]
) -> any HTMLNode {
    HTML.h5(attrs, content)
}

@inlinable
public func h6(
    _ attrs: HTMLAttribute = [:],
    @HTMLBuilder _ content: () -> [any HTMLNode]
) -> any HTMLNode {
    HTML.h6(attrs, content)
}

@inlinable
public func strong(
    _ attrs: HTMLAttribute = HTMLAttribute(),
    @HTMLBuilder _ content: () -> [any HTMLNode]
) -> any HTMLNode {
    HTML.strong(attrs, content)
}

@inlinable
public func em(
    _ attrs: HTMLAttribute = HTMLAttribute(),
    @HTMLBuilder _ content: () -> [any HTMLNode]
) -> any HTMLNode {
    HTML.em(attrs, content)
}

@inlinable
public func code(
    _ attrs: HTMLAttribute = HTMLAttribute(),
    @HTMLBuilder _ content: () -> [any HTMLNode]
) -> any HTMLNode {
    HTML.code(attrs, content)
}

@inlinable
public func pre(
    _ attrs: HTMLAttribute = HTMLAttribute(),
    @HTMLBuilder _ content: () -> [any HTMLNode]
) -> any HTMLNode {
    HTML.pre(attrs, content)
}

@inlinable
public func a(
    _ href: String,
    _ attrs: HTMLAttribute = HTMLAttribute(),
    @HTMLBuilder _ content: () -> [any HTMLNode]
) -> any HTMLNode {
    HTML.a(href, attrs, content)
}

@inlinable
public func a(
    _ attrs: HTMLAttribute = [:],
    @HTMLBuilder _ content: () -> [any HTMLNode]
) -> any HTMLNode {
    HTML.a(attrs, content)
}

@inlinable
public func img(
    src: String,
    alt: String = "",
    _ attrs: HTMLAttribute = HTMLAttribute()
) -> any HTMLNode {
    HTML.img(src: src, alt: alt, attrs)
}

@inlinable
public func ul(
    _ attrs: HTMLAttribute = HTMLAttribute(),
    @HTMLBuilder _ content: () -> [any HTMLNode]
) -> any HTMLNode {
    HTML.ul(attrs, content)
}

@inlinable
public func ol(
    _ attrs: HTMLAttribute = HTMLAttribute(),
    @HTMLBuilder _ content: () -> [any HTMLNode]
) -> any HTMLNode {
    HTML.ol(attrs, content)
}

@inlinable
public func li(
    _ attrs: HTMLAttribute = HTMLAttribute(),
    @HTMLBuilder _ content: () -> [any HTMLNode]
) -> any HTMLNode {
    HTML.li(attrs, content)
}

@inlinable
public func form(
    _ attrs: HTMLAttribute = [:],
    @HTMLBuilder _ content: () -> [any HTMLNode]
) -> any HTMLNode {
    HTML.form(attrs, content)
}

@inlinable
public func table(
    _ attrs: HTMLAttribute = [:],
    @HTMLBuilder _ content: () -> [any HTMLNode]
) -> any HTMLNode { HTML.table(attrs, content) }

@inlinable
public func tr(
    _ attrs: HTMLAttribute = [:],
    @HTMLBuilder _ content: () -> [any HTMLNode]
) -> any HTMLNode { HTML.tr(attrs, content) }

@inlinable
public func td(
    _ attrs: HTMLAttribute = [:],
    @HTMLBuilder _ content: () -> [any HTMLNode]
) -> any HTMLNode { HTML.td(attrs, content) }

@inlinable
public func input(
    _ attrs: HTMLAttribute = [:]
) -> any HTMLNode {
    HTML.input(attrs)
}

@inlinable
public func label(
    _ attrs: HTMLAttribute = [:],
    @HTMLBuilder _ content: () -> [any HTMLNode]
) -> any HTMLNode {
    HTML.label(attrs, content)
}

@inlinable
public func button(
    _ attrs: HTMLAttribute = [:],
    @HTMLBuilder _ content: () -> [any HTMLNode]
) -> any HTMLNode {
    HTML.button(attrs, content)
}

@inlinable
public func textarea(
    _ attrs: HTMLAttribute = [:],
    @HTMLBuilder _ content: () -> [any HTMLNode]
) -> any HTMLNode {
    HTML.textarea(attrs, content)
}

@inlinable
public func fieldset(
    _ attrs: HTMLAttribute = [:],
    @HTMLBuilder _ content: () -> [any HTMLNode]
) -> any HTMLNode {
    HTML.fieldset(attrs, content)
}

@inlinable
public func legend(
    _ attrs: HTMLAttribute = [:],
    @HTMLBuilder _ content: () -> [any HTMLNode]
) -> any HTMLNode {
    HTML.legend(attrs, content)
}

@inlinable
public func select(
    _ attrs: HTMLAttribute = [:],
    @HTMLBuilder _ content: () -> [any HTMLNode]
) -> any HTMLNode {
    HTML.select(attrs, content)
}

@inlinable
public func option(
    _ attrs: HTMLAttribute = [:],
    @HTMLBuilder _ content: () -> [any HTMLNode]
) -> any HTMLNode {
    HTML.option(attrs, content)
}
