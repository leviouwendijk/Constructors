import Foundation
import Path
import Writers

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

    /// Compatibility case retained from the initial filesystem backend.
    ///
    /// Writers now owns intermediate-directory creation, so the current
    /// backend no longer emits this case directly. Its API fate belongs to the
    /// post-0G Guidelines/API review rather than this backend cutover.
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
/// Constructors owns materialization-specific delivery semantics:
///
/// - the explicit filesystem root;
/// - `StandardPath` -> concrete URL lowering;
/// - root containment;
/// - complete destination planning before mutation;
/// - duplicate-destination rejection;
/// - translation of backend failures into this boundary.
///
/// Writers owns general-purpose physical file IO:
///
/// - intermediate-directory creation;
/// - textual encoding;
/// - overwrite execution;
/// - atomic file replacement.
///
/// Writers itself explicitly depends on IO, so generic filesystem mechanics
/// remain below the Constructors materialization layer.
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
    /// Every destination and collision is validated before the first backend
    /// write is attempted.
    ///
    /// The Writers configuration preserves the generated-artifact behavior
    /// established by the original implementation:
    ///
    /// - existing generated files are overwritten;
    /// - overwrite backups are disabled;
    /// - intermediate directories are created;
    /// - writes are atomic;
    /// - text is written as UTF-8 by `FileWriter.write(_:encoding:options:)`.
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
            do {
                _ =
                    try FileWriter(
                        plan
                            .destination
                    )
                    .write(
                        plan
                            .artifact
                            .contents,
                        encoding:
                            .utf8,
                        options:
                            Self
                                .writeOptions
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

    private static let writeOptions =
        SafeWriteOptions(
            existingFilePolicy:
                .overwrite,
            makeBackupOnOverride:
                false,
            createIntermediateDirectories:
                true,
            atomic:
                true,
            createBackupDirectory:
                false,
            backupPolicy:
                .disabled
        )

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
