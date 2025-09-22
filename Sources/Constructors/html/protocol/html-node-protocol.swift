import Foundation

public protocol HTMLNode {
    func render(pretty: Bool, indent: Int, indentStep: Int) -> String
}
