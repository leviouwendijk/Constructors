import Foundation

/// Internal helper node for emitting a DOCTYPE line.
public struct HTMLDoctype: HTMLNode {
    public enum Kind: Sendable {
        case html5
    }

    public let kind: Kind

    public init(_ kind: Kind = .html5) {
        self.kind = kind
    }

    public func render(options: HTMLRenderOptions = .init(), indent: Int = 0) -> String {
        switch kind {
        case .html5:
            return "<!DOCTYPE html>\n"
        }
    }
}
