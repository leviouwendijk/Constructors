import Foundation

/// One validated filesystem destination before mutation.
///
/// The source remains the complete delivery payload. The writer does not need
/// to recover a path or contents from any higher-level HTML/CSS/site model.
public struct StaticFileWritePlan:
    Sendable,
    Equatable
{
    public let artifact:
        StaticTextArtifact

    public let destination:
        URL

    public init(
        artifact:
            StaticTextArtifact,
        destination:
            URL
    ) {
        self.artifact =
            artifact

        self.destination =
            destination
    }
}

/// One successfully-written textual artifact.
public struct StaticWrittenArtifact:
    Sendable,
    Equatable
{
    public let artifact:
        StaticTextArtifact

    public let destination:
        URL

    public init(
        artifact:
            StaticTextArtifact,
        destination:
            URL
    ) {
        self.artifact =
            artifact

        self.destination =
            destination
    }
}

/// Concrete result of filesystem delivery.
///
/// This result is intentionally independent from site/rendering semantics. It
/// exists so callers can report exactly which generated artifacts were written
/// and where.
public struct StaticFileWriteResult:
    Sendable,
    Equatable
{
    public let root:
        URL

    public let written:
        [StaticWrittenArtifact]

    public init(
        root:
            URL,
        written:
            [StaticWrittenArtifact]
    ) {
        self.root =
            root

        self.written =
            written
    }

    public var destinations:
        [URL]
    {
        written
            .map(
                \.destination
            )
    }
}
