import Foundation

public typealias HTMLFragment = [any HTMLNode]

extension Array where Element == any HTMLNode {
    public var htmlDocument: HTMLDocument {
        HTMLDocument(children: self)
    }

    public func render(options: HTMLRenderOptions = .Defaults.pretty()) -> String {
        htmlDocument.render(options: options)
    }

    public func renderFragment(options: HTMLRenderOptions = .Defaults.pretty(doctype: false)) -> String {
        var opts = options
        opts.doctype = false
        return render(options: opts)
    }
}
