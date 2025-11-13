import Foundation

public enum HTML {
    public static func el(
        _ tag: String,
        _ attrs: HTMLAttribute = HTMLAttribute(),
        @HTMLBuilder _ children: () -> [any HTMLNode] = { [] }
    ) -> any HTMLNode {
        HTMLElement(tag, attrs: attrs, children: children())
    }

    public static func document(@HTMLBuilder _ body: () -> [any HTMLNode]) -> HTMLDocument {
        HTMLDocument(children: body())
    }

    public static func html(_ attrs: HTMLAttribute = HTMLAttribute(), @HTMLBuilder _ c: () -> [any HTMLNode]) -> any HTMLNode { el("html", attrs, c) }
    public static func head(_ attrs: HTMLAttribute = HTMLAttribute(), @HTMLBuilder _ c: () -> [any HTMLNode]) -> any HTMLNode { el("head", attrs, c) }
    public static func body(_ attrs: HTMLAttribute = HTMLAttribute(), @HTMLBuilder _ c: () -> [any HTMLNode]) -> any HTMLNode { el("body", attrs, c) }

    // Head primitives
    public static func meta(_ attrs: HTMLAttribute) -> any HTMLNode { el("meta", attrs) }
    public static func title(_ text: String) -> any HTMLNode { HTMLElement("title", children: [HTMLText(text)]) }

    @available(*, deprecated, message: "Use HTML.link(.stylesheet(href:))")
    public static func linkStylesheet(href: String) -> any HTMLNode { el("link", ["rel":"stylesheet","href": href]) }

    public static func stylsheet(href: String) -> any HTMLNode { el("link", ["rel":"stylesheet","href": href]) }

    public static func style(_ css: String) -> any HTMLNode { HTMLElement("style", children: [HTMLRaw(css)]) }

    // Body common
    public static func div(_ attrs: HTMLAttribute = HTMLAttribute(), @HTMLBuilder _ c: () -> [any HTMLNode]) -> any HTMLNode { el("div", attrs, c) }
    public static func p(_ attrs: HTMLAttribute = HTMLAttribute(), @HTMLBuilder _ c: () -> [any HTMLNode]) -> any HTMLNode { el("p", attrs, c) }
    public static func span(_ attrs: HTMLAttribute = HTMLAttribute(), @HTMLBuilder _ c: () -> [any HTMLNode]) -> any HTMLNode { el("span", attrs, c) }
    public static func a(_ href: String, _ attrs: HTMLAttribute = HTMLAttribute(), @HTMLBuilder _ c: () -> [any HTMLNode]) -> any HTMLNode {
        var merged = attrs; merged.merge(["href": href]); return el("a", merged, c)
    }
    // without href requirement
    public static func a(_ attrs: HTMLAttribute = [:],
                  @HTMLBuilder _ children: () -> [any HTMLNode]) -> any HTMLNode
    {
        el("a", attrs, children)
    }

    public static func img(src: String, alt: String = "", _ attrs: HTMLAttribute = HTMLAttribute()) -> any HTMLNode {
        var merged = attrs; merged.merge(["src": src, "alt": alt]); return el("img", merged)
    }
    public static func br() -> any HTMLNode { el("br") }
    public static func br(_ n: Int) -> HTMLFragment { Array(repeating: HTML.br(), count: n) }

    public static func hr(_ attrs: HTMLAttribute = HTMLAttribute()) -> any HTMLNode { el("hr", attrs) }

    public static func code(_ attrs: HTMLAttribute = HTMLAttribute(), @HTMLBuilder _ c: () -> [any HTMLNode]) -> any HTMLNode { el("code", attrs, c) }
    public static func pre(_ attrs: HTMLAttribute = HTMLAttribute(), @HTMLBuilder _ c: () -> [any HTMLNode]) -> any HTMLNode { el("pre", attrs, c) }

    // Lists
    public static func ul(_ attrs: HTMLAttribute = HTMLAttribute(), @HTMLBuilder _ c: () -> [any HTMLNode]) -> any HTMLNode { el("ul", attrs, c) }
    public static func ol(_ attrs: HTMLAttribute = HTMLAttribute(), @HTMLBuilder _ c: () -> [any HTMLNode]) -> any HTMLNode { el("ol", attrs, c) }
    public static func li(_ attrs: HTMLAttribute = HTMLAttribute(), @HTMLBuilder _ c: () -> [any HTMLNode]) -> any HTMLNode { el("li", attrs, c) }

    // Tables
    public static func table(_ attrs: HTMLAttribute = HTMLAttribute(), @HTMLBuilder _ c: () -> [any HTMLNode]) -> any HTMLNode { el("table", attrs, c) }
    public static func thead(_ attrs: HTMLAttribute = HTMLAttribute(), @HTMLBuilder _ c: () -> [any HTMLNode]) -> any HTMLNode { el("thead", attrs, c) }
    public static func tbody(_ attrs: HTMLAttribute = HTMLAttribute(), @HTMLBuilder _ c: () -> [any HTMLNode]) -> any HTMLNode { el("tbody", attrs, c) }
    public static func tr(_ attrs: HTMLAttribute = HTMLAttribute(), @HTMLBuilder _ c: () -> [any HTMLNode]) -> any HTMLNode { el("tr", attrs, c) }
    public static func th(_ attrs: HTMLAttribute = HTMLAttribute(), @HTMLBuilder _ c: () -> [any HTMLNode]) -> any HTMLNode { el("th", attrs, c) }
    public static func td(_ attrs: HTMLAttribute = HTMLAttribute(), @HTMLBuilder _ c: () -> [any HTMLNode]) -> any HTMLNode { el("td", attrs, c) }

    // Text
    public static func text(_ s: String) -> any HTMLNode { HTMLText(s) }
    public static func raw(_ s: String)  -> any HTMLNode { HTMLRaw(s) }

    public static func b(_ attrs: HTMLAttribute = HTMLAttribute(), @HTMLBuilder _ c: () -> [any HTMLNode]) -> any HTMLNode {
        el("b", attrs, c)
    }

    public static func i(_ attrs: HTMLAttribute = HTMLAttribute(), @HTMLBuilder _ c: () -> [any HTMLNode]) -> any HTMLNode {
        el("i", attrs, c)
    }

    public static func strong(_ attrs: HTMLAttribute = HTMLAttribute(), @HTMLBuilder _ c: () -> [any HTMLNode]) -> any HTMLNode {
        el("strong", attrs, c)
    }

    public static func em(_ attrs: HTMLAttribute = HTMLAttribute(), @HTMLBuilder _ c: () -> [any HTMLNode]) -> any HTMLNode {
        el("em", attrs, c)
    }

    @inlinable
    public static func repeating(_ n: Int, @HTMLBuilder builder: () -> [any HTMLNode]) -> [any HTMLNode] {
        var out: [any HTMLNode] = []
        for _ in 0..<n {
            out.append(contentsOf: builder())
        }
        return out
    }

    public static func `if`(_ condition: Bool, @HTMLBuilder _ content: () -> HTMLFragment) -> HTMLFragment {
        condition ? content() : []
    }

    public static func comment(_ s: String) -> any HTMLNode { HTMLComment(text: s) }

    public static func elSC(_ tag: String, _ attrs: HTMLAttribute = HTMLAttribute()) -> any HTMLNode {
        HTMLElement(tag, attrs: attrs, children: [], selfClosing: true)
    }

    /// Insert `count` line breaks at this point in the output (pretty mode only).
    public static func newline(_ count: Int = 1) -> any HTMLNode { HTMLNewline(count) }

    /// Convenience: adds a *blank line* (i.e., one empty line between blocks).
    /// Use `blank()` between major sections for readability.
    public static func blank() -> any HTMLNode { HTMLNewline(1) }

    public static func inline(@HTMLBuilder _ c: () -> [any HTMLNode]) -> any HTMLNode {
        HTMLInlineGroup(c())
    }

    public static func header(_ a: HTMLAttribute = [:], @HTMLBuilder _ c: () -> [any HTMLNode]) -> any HTMLNode { el("header", a, c) }
    public static func footer(_ a: HTMLAttribute = [:], @HTMLBuilder _ c: () -> [any HTMLNode]) -> any HTMLNode { el("footer", a, c) }
    public static func section(_ a: HTMLAttribute = [:], @HTMLBuilder _ c: () -> [any HTMLNode]) -> any HTMLNode { el("section", a, c) }
    public static func figure(_ a: HTMLAttribute = [:], @HTMLBuilder _ c: () -> [any HTMLNode]) -> any HTMLNode { el("figure", a, c) }
    public static func figcaption(_ a: HTMLAttribute = [:], @HTMLBuilder _ c: () -> [any HTMLNode]) -> any HTMLNode { el("figcaption", a, c) }
    public static func blockquote(_ a: HTMLAttribute = [:], @HTMLBuilder _ c: () -> [any HTMLNode]) -> any HTMLNode { el("blockquote", a, c) }

    public static func h1(_ a: HTMLAttribute = [:], @HTMLBuilder _ c: () -> [any HTMLNode]) -> any HTMLNode { el("h1", a, c) }
    public static func h2(_ a: HTMLAttribute = [:], @HTMLBuilder _ c: () -> [any HTMLNode]) -> any HTMLNode { el("h2", a, c) }
    public static func h3(_ a: HTMLAttribute = [:], @HTMLBuilder _ c: () -> [any HTMLNode]) -> any HTMLNode { el("h3", a, c) }
    public static func h4(_ a: HTMLAttribute = [:], @HTMLBuilder _ c: () -> [any HTMLNode]) -> any HTMLNode { el("h4", a, c) }
    public static func h5(_ a: HTMLAttribute = [:], @HTMLBuilder _ c: () -> [any HTMLNode]) -> any HTMLNode { el("h5", a, c) }
    public static func h6(_ a: HTMLAttribute = [:], @HTMLBuilder _ c: () -> [any HTMLNode]) -> any HTMLNode { el("h6", a, c) }

    public static func picture(_ a: HTMLAttribute = [:], @HTMLBuilder _ c: () -> [any HTMLNode]) -> any HTMLNode { el("picture", a, c) }
    public static func source(_ a: HTMLAttribute = [:]) -> any HTMLNode { el("source", a) }  // void handled centrally
    public static func svg(_ a: HTMLAttribute = [:], @HTMLBuilder _ c: () -> [any HTMLNode]) -> any HTMLNode { el("svg", a, c) }
    public static func path(_ a: HTMLAttribute = [:]) -> any HTMLNode { elSC("path", a) }

    public static func form(_ a: HTMLAttribute = [:], @HTMLBuilder _ c: () -> [any HTMLNode]) -> any HTMLNode { el("form", a, c) }
    public static func input(_ a: HTMLAttribute = [:]) -> any HTMLNode { el("input", a) }
    public static func label(_ a: HTMLAttribute = [:], @HTMLBuilder _ c: () -> [any HTMLNode]) -> any HTMLNode { el("label", a, c) }
    public static func button(_ a: HTMLAttribute = [:], @HTMLBuilder _ c: () -> [any HTMLNode]) -> any HTMLNode { el("button", a, c) }
    public static func textarea(_ a: HTMLAttribute = [:], @HTMLBuilder _ c: () -> [any HTMLNode]) -> any HTMLNode { el("textarea", a, c) }

    public static func type(_ value: String) -> HTMLAttribute { ["type": value] }
    public static func name(_ value: String) -> HTMLAttribute { ["name": value] }
    public static func value(_ value: String) -> HTMLAttribute { ["value": value] }
    public static func placeholder(_ value: String) -> HTMLAttribute { ["placeholder": value] }

    // boolean conveniences
    public static func checked(_ enabled: Bool = true) -> HTMLAttribute { .bool("checked", enabled) }
    public static func disabled(_ enabled: Bool = true) -> HTMLAttribute { .bool("disabled", enabled) }
    public static func readonly(_ enabled: Bool = true) -> HTMLAttribute { .bool("readonly", enabled) }
    public static func required(_ enabled: Bool = true) -> HTMLAttribute { .bool("required", enabled) }

    public static func select(_ a: HTMLAttribute = [:], @HTMLBuilder _ c: () -> [any HTMLNode]) -> any HTMLNode {
        el("select", a, c)
    }
    public static func option(_ a: HTMLAttribute = [:], @HTMLBuilder _ c: () -> [any HTMLNode]) -> any HTMLNode {
        el("option", a, c)
    }
    public static func optgroup(_ a: HTMLAttribute = [:], @HTMLBuilder _ c: () -> [any HTMLNode]) -> any HTMLNode {
        el("optgroup", a, c)
    }
}

public extension HTML {
    @inlinable
    static func attrs(_ parts: HTMLAttribute...) -> HTMLAttribute {
        var out = HTMLAttribute()
        for p in parts { out.merge(p) }
        return out
    }
}

public extension HTML {
    static func script(
        src: String,
       defer: Bool = false,
       `async`: Bool = false,
       type: String? = nil,
       integrity: String? = nil,
       crossorigin: String? = nil,
        nonce: String? = nil,
       _ extra: HTMLAttribute = HTMLAttribute()
    ) -> any HTMLNode {
        var a = extra
        a.merge(["src": src])
        if let type { a.merge(["type": type]) }
        if let integrity { a.merge(["integrity": integrity]) }
        if let crossorigin { a.merge(["crossorigin": crossorigin]) }
        if let nonce { a.merge(["nonce": nonce]) }
        if `defer` { a.merge(.bool("defer", true)) }
        if async { a.merge(.bool("async", true)) }
        return el("script", a)
    }

    static func scriptInline(_ js: String, type: String? = nil, nonce: String? = nil) -> any HTMLNode {
        var a: HTMLAttribute = [:]
        if let type { a.merge(["type": type]) }
        if let nonce { a.merge(["nonce": nonce]) }
        return el("script", a) { [HTML.raw(js)] }
    }

    static func scriptCall(_ fn: String, args: [JSValue], type: String? = "module") -> any HTMLNode {
        HTML.scriptInline(JS.call(fn, args), type: type)
    }

    /// Emit `<script type="application/json" id="...">…</script>` for props
    static func jsonProps(id: String, _ value: JSValue) -> any HTMLNode {
        HTML.el("script", ["type":"application/json","id": id]) {
            HTML.raw(value.render()) // contents are JSON, not escaped text
        }
    }

    static func link(_ spec: HTMLLinkSpec, _ extra: HTMLAttribute = [:]) -> any HTMLNode {
        var a = spec.attributes()
        a.merge(extra) 
        return el("link", a)
    }

    static func meta(_ spec: HTMLMetaSpec, _ extra: HTMLAttribute = [:]) -> any HTMLNode {
        var a = spec.attributes()
        a.merge(extra)
        return el("meta", a)
    }
}

public extension HTML {
    static func style(_ sheet: CSSStyleSheet) -> any HTMLNode {
        HTML.el("style") {
            HTML.raw(sheet.render())
        }
    }
}
