import Foundation

public struct ICSRenderOptions: Sendable {
    /// Line separator; ICS wants CRLF.
    public var lineSeparator: String
    /// Whether to fold long lines.
    public var foldLines: Bool
    /// Max chars per line before folding (ICS spec ~75 bytes).
    public var maxLineLength: Int

    public init(
        lineSeparator: String = "\r\n",
        foldLines: Bool = true,
        maxLineLength: Int = 75
    ) {
        self.lineSeparator = lineSeparator
        self.foldLines = foldLines
        self.maxLineLength = maxLineLength
    }
}

public protocol ICSNode: Sendable {
    /// Return *logical* lines; caller is responsible for joining with separators.
    func lines(options: ICSRenderOptions) -> [String]
}
