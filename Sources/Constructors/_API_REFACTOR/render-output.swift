import Path

public struct RenderOutput: Sendable {
    public let files: [RenderedFile]

    public init(
        files: [RenderedFile]
    ) {
        self.files = files
    }
}

public struct RenderedFile: Sendable {
    public let output: StandardPath
    public let content: String

    public init(
        output: StandardPath,
        content: String
    ) {
        self.output = output
        self.content = content
    }
}
