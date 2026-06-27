import Path
import Primitives

public struct PageRoute<Identifier: StringIdentifier>: Sendable, Hashable {
    public let identifier: Identifier
    public let segments: [PathSegment]

    public init(
        identifier: Identifier,
        segments: [PathSegment]
    ) {
        self.identifier = identifier
        self.segments = segments
    }

    public var directory: StandardPath {
        StandardPath(
            segments: segments.map { segment in
                PathSegment(
                    segment.value,
                    .directory
                )
            }
        )
    }

    public var indexOutputWithoutFiletype: StandardPath {
        directory.merged(
            appending: StandardPath(
                [
                    PathSegment(
                        "index",
                        .file
                    )
                ]
            )
        )
    }

    public var href: String {
        let rendered = directory.render(
            as: .root,
            filetype: false
        )

        if rendered.isEmpty || rendered == "/" {
            return "/"
        }

        if rendered.hasSuffix("/") {
            return rendered
        }

        return "\(rendered)/"
    }
}
