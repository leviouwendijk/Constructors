import Foundation

public protocol HTMLNode {
    func _render(pretty: Bool, indent: Int, indentStep: Int) -> String
}
