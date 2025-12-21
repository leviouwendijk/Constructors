import Foundation

public typealias HTMLFragment = [any HTMLNode]

extension Array where Element == any HTMLNode {
    @available(*, message: "Being deprecated in favor of a better API, use <nodes>.doc or .document instead")
    public var htmlDocument: HTMLDocument {
        HTMLDocument(children: self)
    }

    public var doc: HTMLDocument {
        HTMLDocument(children: self)
    }

    public var document: HTMLDocument {
        HTMLDocument(children: self)
    }

    @available(*, message: "use more explicit and conscious render_doc() method instead, use snippet() for snippets.")
    public func render(options: HTMLRenderOptions = .Defaults.pretty()) -> String {
        htmlDocument.render(options: options)
    }

    public func render_doc(options: HTMLRenderOptions = .Defaults.pretty()) -> String {
        htmlDocument.render(options: options)
    }

    public func snippet(options: HTMLRenderOptions = .Defaults.pretty(doctype: false)) -> String {
        var opts = options
        opts.doctype = false
        return render(options: opts)
    }
}
