import Foundation

public protocol HTMLNode: Sendable {
    @available(*, deprecated, message: "Use the options-aware render(_:indent:indentStep:options:) overload.")
    func render(pretty: Bool, indent: Int, indentStep: Int) -> String

    func render(options: HTMLRenderOptions, indent: Int) -> String
}

public extension HTMLNode {
    func render(pretty: Bool, indent: Int, indentStep: Int) -> String {
        let opts = HTMLRenderOptions(
            pretty: pretty,
            indentStep: indentStep,
            attributeOrder: .ranked,
            ensureTrailingNewline: false
        )

        return render(options: opts, indent: indent)
    }
}
