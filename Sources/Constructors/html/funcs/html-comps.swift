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
    public static func linkStylesheet(href: String) -> any HTMLNode { el("link", ["rel":"stylesheet","href": href]) }
    public static func style(_ css: String) -> any HTMLNode { HTMLElement("style", children: [HTMLRaw(css)]) }

    // Body common
    public static func div(_ attrs: HTMLAttribute = HTMLAttribute(), @HTMLBuilder _ c: () -> [any HTMLNode]) -> any HTMLNode { el("div", attrs, c) }
    public static func p(_ attrs: HTMLAttribute = HTMLAttribute(), @HTMLBuilder _ c: () -> [any HTMLNode]) -> any HTMLNode { el("p", attrs, c) }
    public static func span(_ attrs: HTMLAttribute = HTMLAttribute(), @HTMLBuilder _ c: () -> [any HTMLNode]) -> any HTMLNode { el("span", attrs, c) }
    public static func a(_ href: String, _ attrs: HTMLAttribute = HTMLAttribute(), @HTMLBuilder _ c: () -> [any HTMLNode]) -> any HTMLNode {
        var merged = attrs; merged.merge(["href": href]); return el("a", merged, c)
    }
    public static func img(src: String, alt: String = "", _ attrs: HTMLAttribute = HTMLAttribute()) -> any HTMLNode {
        var merged = attrs; merged.merge(["src": src, "alt": alt]); return el("img", merged)
    }
    public static func br() -> any HTMLNode { el("br") }
    public static func hr(_ attrs: HTMLAttribute = HTMLAttribute()) -> any HTMLNode { el("hr", attrs) }

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

    @inlinable
    public static func repeating(_ n: Int, @HTMLBuilder builder: () -> [any HTMLNode]) -> [any HTMLNode] {
        var out: [any HTMLNode] = []
        for _ in 0..<n {
            out.append(contentsOf: builder())
        }
        return out
    }
}
