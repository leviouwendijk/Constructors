import Foundation
import Path

public enum StaticFileWriterError:
    Error,
    Sendable,
    Equatable
{
    case nonFileRoot(
        String
    )

    case destinationOutsideRoot(
        output:
            StandardPath,
        root:
            String,
        resolved:
            String
    )

    case duplicateDestination(
        String
    )

    case createDirectoryFailed(
        destination:
            String,
        reason:
            String
    )

    case writeFailed(
        destination:
            String,
        reason:
            String
    )
}

/// Filesystem delivery for already-serialized static text artifacts.
///
/// This is intentionally a lower-level boundary than HTML/CSS/site
/// materialization:
///
///     StaticTextArtifact
///         StandardPath
///         String
///             +
///     explicit filesystem root
///             ↓
///     concrete file URL
///             ↓
///     directory creation + atomic write
///
/// The complete destination set is resolved and validated before the first
/// filesystem mutation occurs.
public struct StaticFileWriter:
    Sendable
{
    public let root:
        URL

    public init(
        root:
            URL
    ) throws {
        guard
            root
                .isFileURL
        else {
            throw
                StaticFileWriterError
                    .nonFileRoot(
                        root
                            .absoluteString
                    )
        }

        self.root =
            root
                .standardizedFileURL
    }

    /// Resolve and validate the complete delivery set without touching disk.
    public func plan(
        _ artifacts:
            [StaticTextArtifact]
    ) throws -> [StaticFileWritePlan] {
        var destinations:
            Set<String> = []

        return
            try artifacts
                .map { artifact in
                    let destination =
                        try destination(
                            for:
                                artifact
                        )

                    let key =
                        destination
                            .path

                    guard
                        destinations
                            .insert(
                                key
                            )
                            .inserted
                    else {
                        throw
                            StaticFileWriterError
                                .duplicateDestination(
                                    key
                                )
                    }

                    return
                        StaticFileWritePlan(
                            artifact:
                                artifact,
                            destination:
                                destination
                        )
                }
    }

    /// Deliver an already-serialized artifact set to this writer's root.
    ///
    /// Every path and collision is validated first. Each individual payload is
    /// then written atomically at its destination.
    public func write(
        _ artifacts:
            [StaticTextArtifact]
    ) throws -> StaticFileWriteResult {
        let plans =
            try plan(
                artifacts
            )

        var written:
            [StaticWrittenArtifact] = []

        written
            .reserveCapacity(
                plans.count
            )

        for plan in plans {
            let parent =
                plan
                    .destination
                    .deletingLastPathComponent()

            do {
                try FileManager
                    .default
                    .createDirectory(
                        at:
                            parent,
                        withIntermediateDirectories:
                            true
                    )
            } catch {
                throw
                    StaticFileWriterError
                        .createDirectoryFailed(
                            destination:
                                parent
                                    .path,
                            reason:
                                String(
                                    describing:
                                        error
                                )
                        )
            }

            do {
                try Data(
                    plan
                        .artifact
                        .contents
                        .utf8
                )
                .write(
                    to:
                        plan
                            .destination,
                    options:
                        .atomic
                )
            } catch {
                throw
                    StaticFileWriterError
                        .writeFailed(
                            destination:
                                plan
                                    .destination
                                    .path,
                            reason:
                                String(
                                    describing:
                                        error
                                )
                        )
            }

            written
                .append(
                    StaticWrittenArtifact(
                        artifact:
                            plan
                                .artifact,
                        destination:
                            plan
                                .destination
                    )
                )
        }

        return
            StaticFileWriteResult(
                root:
                    root,
                written:
                    written
            )
    }

    private func destination(
        for artifact:
            StaticTextArtifact
    ) throws -> URL {
        let resolved =
            artifact
                .output
                .url(
                    base:
                        root
                )
                .standardizedFileURL

        guard
            isStrictDescendant(
                resolved,
                of:
                    root
            )
        else {
            throw
                StaticFileWriterError
                    .destinationOutsideRoot(
                        output:
                            artifact
                                .output,
                        root:
                            root
                                .path,
                        resolved:
                            resolved
                                .path
                    )
        }

        return
            resolved
    }

    private func isStrictDescendant(
        _ candidate:
            URL,
        of root:
            URL
    ) -> Bool {
        let rootComponents =
            root
                .standardizedFileURL
                .pathComponents

        let candidateComponents =
            candidate
                .standardizedFileURL
                .pathComponents

        guard
            candidateComponents
                .count
                > rootComponents
                    .count
        else {
            return
                false
        }

        return
            Array(
                candidateComponents
                    .prefix(
                        rootComponents
                            .count
                    )
            )
            == rootComponents
    }
}
