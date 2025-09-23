import Foundation

public protocol HTMLNode: Sendable {
    func render(pretty: Bool, indent: Int, indentStep: Int) -> String
}
