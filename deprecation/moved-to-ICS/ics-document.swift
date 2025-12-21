import Foundation

public struct ICSDocument: Sendable {
    public var children: [any ICSNode]

    public init(children: [any ICSNode]) {
        self.children = children
    }

    public func render(options: ICSRenderOptions = .init()) -> String {
        children
            .flatMap { $0.lines(options: options) }
            .joined(separator: options.lineSeparator)
    }
}
