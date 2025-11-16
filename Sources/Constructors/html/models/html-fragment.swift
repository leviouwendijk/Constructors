import Foundation

public typealias HTMLFragment = [any HTMLNode]

extension Array where Element == any HTMLNode {
    var htmlDocument: HTMLDocument {
        HTMLDocument(children: self)
    }

    func render(options: HTMLRenderOptions = .init()) -> String {
        htmlDocument.render(options: options)
    }
}
