import Constructors
import Foundation
import Path
import TestFlows

extension ConstructorsFlowSuite {
    static let staticFileWriter =
        TestFlow(
            "static-file-writer",
            title:
                "Static filesystem delivery consumes only validated StandardPath plus serialized text payloads",
            tags: [
                "constructors",
                "filesystem",
                "materialization",
                "path",
                "static",
                "writer",
            ]
        ) {
            Step(
                "planning deterministically lowers StandardPath beneath an explicit root without touching disk"
            ) {
                let root =
                    staticWriterTemporaryRoot(
                        "planning"
                    )

                defer {
                    try?
                        FileManager
                            .default
                            .removeItem(
                                at:
                                    root
                            )
                }

                let writer =
                    try StaticFileWriter(
                        root:
                            root
                    )

                let artifacts =
                    staticWriterFixtureArtifacts()

                let plans =
                    try writer
                        .plan(
                            artifacts
                        )

                try Expect.equal(
                    plans
                        .map {
                            $0
                                .destination
                                .path
                        },
                    [
                        root
                            .appendingPathComponent(
                                "index.html"
                            )
                            .standardizedFileURL
                            .path,
                        root
                            .appendingPathComponent(
                                "account/index.html"
                            )
                            .standardizedFileURL
                            .path,
                        root
                            .appendingPathComponent(
                                "assets/css/site.css"
                            )
                            .standardizedFileURL
                            .path,
                    ],
                    "static-writer.deterministic-destination-lowering"
                )

                try Expect.equal(
                    plans
                        .map(
                            \.artifact
                        ),
                    artifacts,
                    "static-writer.planning-preserves-artifact-order"
                )

                try Expect.equal(
                    FileManager
                        .default
                        .fileExists(
                            atPath:
                                root
                                    .path
                        ),
                    false,
                    "static-writer.planning-is-write-free"
                )
            }

            Step(
                "writing creates nested directories and preserves exact serialized contents"
            ) {
                let root =
                    staticWriterTemporaryRoot(
                        "write"
                    )

                defer {
                    try?
                        FileManager
                            .default
                            .removeItem(
                                at:
                                    root
                            )
                }

                let artifacts =
                    staticWriterFixtureArtifacts()

                let writer =
                    try StaticFileWriter(
                        root:
                            root
                    )

                let result =
                    try writer
                        .write(
                            artifacts
                        )

                try Expect.equal(
                    result
                        .root,
                    root
                        .standardizedFileURL,
                    "static-writer.result-root"
                )

                try Expect.equal(
                    result
                        .written
                        .map {
                            $0
                                .artifact
                        },
                    artifacts,
                    "static-writer.result-preserves-source-artifacts"
                )

                try Expect.equal(
                    result
                        .destinations,
                    artifacts
                        .map {
                            $0
                                .output
                                .url(
                                    base:
                                        root
                                )
                                .standardizedFileURL
                        },
                    "static-writer.result-concrete-destinations"
                )

                for written in result
                    .written
                {
                    let data =
                        try Data(
                            contentsOf:
                                written
                                    .destination
                        )

                    try Expect.equal(
                        String(
                            decoding:
                                data,
                            as:
                                UTF8
                                    .self
                        ),
                        written
                            .artifact
                            .contents,
                        "static-writer.exact-written-content-\(written.destination.lastPathComponent)"
                    )
                }

                try Expect.equal(
                    FileManager
                        .default
                        .fileExists(
                            atPath:
                                root
                                    .appendingPathComponent(
                                        "account"
                                    )
                                    .path
                        ),
                    true,
                    "static-writer.nested-directory-created"
                )

                try Expect.equal(
                    FileManager
                        .default
                        .fileExists(
                            atPath:
                                root
                                    .appendingPathComponent(
                                        "assets/css"
                                    )
                                    .path
                        ),
                    true,
                    "static-writer.stylesheet-directory-created"
                )
            }

            Step(
                "duplicate destinations are rejected before any filesystem mutation"
            ) {
                let root =
                    staticWriterTemporaryRoot(
                        "duplicate"
                    )

                defer {
                    try?
                        FileManager
                            .default
                            .removeItem(
                                at:
                                    root
                            )
                }

                let writer =
                    try StaticFileWriter(
                        root:
                            root
                    )

                let output =
                    StandardPath(
                        [
                            "duplicate.txt",
                        ]
                    )

                let artifacts = [
                    StaticTextArtifact(
                        output:
                            output,
                        contents:
                            "first"
                    ),
                    StaticTextArtifact(
                        output:
                            output,
                        contents:
                            "second"
                    ),
                ]

                do {
                    _ =
                        try writer
                            .write(
                                artifacts
                            )

                    throw
                        StaticFileWriterFlowFailure
                            .expectedFailure
                } catch
                    let error
                        as StaticFileWriterError
                {
                    try Expect.equal(
                        error,
                        .duplicateDestination(
                            root
                                .appendingPathComponent(
                                    "duplicate.txt"
                                )
                                .standardizedFileURL
                                .path
                        ),
                        "static-writer.duplicate-destination-rejected"
                    )
                }

                try Expect.equal(
                    FileManager
                        .default
                        .fileExists(
                            atPath:
                                root
                                    .path
                        ),
                    false,
                    "static-writer.duplicate-validation-precedes-mutation"
                )
            }

            Step(
                "StandardPath normalization prevents traversal while writer containment still rejects corrupted path state before mutation"
            ) {
                let root =
                    staticWriterTemporaryRoot(
                        "escape"
                    )

                defer {
                    try?
                        FileManager
                            .default
                            .removeItem(
                                at:
                                    root
                            )
                }

                let writer =
                    try StaticFileWriter(
                        root:
                            root
                    )

                /*
                 Raw path input is normalized by Path before it becomes stored
                 StandardPath state.

                 `nested/../../escaped.txt` therefore becomes `escaped.txt`,
                 not a path outside the writer root.
                 */
                let normalizedArtifact =
                    StaticTextArtifact(
                        output:
                            StandardPath(
                                rawPath:
                                    "nested/../../escaped.txt"
                            ),
                        contents:
                            "normalized safely"
                    )

                let normalizedPlan =
                    try writer
                        .plan(
                            [
                                normalizedArtifact,
                            ]
                        )

                try Expect.equal(
                    normalizedPlan
                        .map {
                            $0
                                .destination
                                .path
                        },
                    [
                        root
                            .appendingPathComponent(
                                "escaped.txt"
                            )
                            .standardizedFileURL
                            .path,
                    ],
                    "static-writer.standard-path-normalization-stays-inside-root"
                )

                try Expect.equal(
                    FileManager
                        .default
                        .fileExists(
                            atPath:
                                root
                                    .path
                        ),
                    false,
                    "static-writer.normalization-planning-is-write-free"
                )

                /*
                 StandardPath validates `..` during normal construction.

                 Its stored segments are currently mutable, however, so the
                 filesystem boundary remains defensive against externally
                 corrupted path state rather than assuming that invariant can
                 never be violated after initialization.
                 */
                var corruptedOutput =
                    StandardPath(
                        [
                            "placeholder",
                        ]
                    )

                corruptedOutput
                    .segments = [
                        PathSegment(
                            ".."
                        ),
                        PathSegment(
                            "escaped.txt"
                        ),
                    ]

                let corruptedArtifact =
                    StaticTextArtifact(
                        output:
                            corruptedOutput,
                        contents:
                            "must not escape"
                    )

                do {
                    _ =
                        try writer
                            .write(
                                [
                                    corruptedArtifact,
                                ]
                            )

                    throw
                        StaticFileWriterFlowFailure
                            .expectedFailure
                } catch
                    let error
                        as StaticFileWriterError
                {
                    switch error {
                    case .destinationOutsideRoot(
                        output:
                            let output,
                        root:
                            let actualRoot,
                        resolved:
                            let resolved
                    ):
                        try Expect.equal(
                            output,
                            corruptedArtifact
                                .output,
                            "static-writer.escape-error-retains-output"
                        )

                        try Expect.equal(
                            actualRoot,
                            root
                                .standardizedFileURL
                                .path,
                            "static-writer.escape-error-retains-root"
                        )

                        try Expect.equal(
                            resolved,
                            root
                                .deletingLastPathComponent()
                                .appendingPathComponent(
                                    "escaped.txt"
                                )
                                .standardizedFileURL
                                .path,
                            "static-writer.escape-error-retains-resolved-destination"
                        )

                    default:
                        throw
                            StaticFileWriterFlowFailure
                                .unexpectedWriterError(
                                    String(
                                        describing:
                                            error
                                    )
                                )
                    }
                }

                try Expect.equal(
                    FileManager
                        .default
                        .fileExists(
                            atPath:
                                root
                                    .path
                        ),
                    false,
                    "static-writer.escape-validation-precedes-mutation"
                )
            }

            Step(
                "Writers backend preserves generated-file overwrite semantics without backups"
            ) {
                let root =
                    staticWriterTemporaryRoot(
                        "writers-overwrite"
                    )

                defer {
                    try?
                        FileManager
                            .default
                            .removeItem(
                                at:
                                    root
                            )
                }

                let output =
                    StandardPath(
                        [
                            "nested",
                            "overwrite.txt",
                        ]
                    )

                let writer =
                    try StaticFileWriter(
                        root:
                            root
                    )

                _ =
                    try writer
                        .write(
                            [
                                StaticTextArtifact(
                                    output:
                                        output,
                                    contents:
                                        "first\n"
                                ),
                            ]
                        )

                _ =
                    try writer
                        .write(
                            [
                                StaticTextArtifact(
                                    output:
                                        output,
                                    contents:
                                        "second\n"
                                ),
                            ]
                        )

                let destination =
                    output
                        .url(
                            base:
                                root
                        )
                        .standardizedFileURL

                let contents =
                    try String(
                        contentsOf:
                            destination,
                        encoding:
                            .utf8
                    )

                try Expect.equal(
                    contents,
                    "second\n",
                    "static-writer.writers-backend-overwrite"
                )

                let nested =
                    destination
                        .deletingLastPathComponent()

                let nestedEntries =
                    try FileManager
                        .default
                        .contentsOfDirectory(
                            at:
                                nested,
                            includingPropertiesForKeys:
                                nil
                        )
                        .map(
                            \.lastPathComponent
                        )
                        .sorted()

                try Expect.equal(
                    nestedEntries,
                    [
                        "overwrite.txt",
                    ],
                    "static-writer.writers-backend-no-sibling-backup"
                )

                try Expect.equal(
                    FileManager
                        .default
                        .fileExists(
                            atPath:
                                root
                                    .appendingPathComponent(
                                        "safe-file-backups"
                                    )
                                    .path
                        ),
                    false,
                    "static-writer.writers-backend-no-backup-directory"
                )

                try Expect.equal(
                    FileManager
                        .default
                        .fileExists(
                            atPath:
                                nested
                                    .path
                        ),
                    true,
                    "static-writer.writers-backend-created-intermediate-directory"
                )
            }

            Step(
                "filesystem writer rejects non-file roots"
            ) {
                guard
                    let remote =
                        URL(
                            string:
                                "https://example.com/output/"
                        )
                else {
                    throw
                        StaticFileWriterFlowFailure
                            .invalidFixtureURL
                }

                do {
                    _ =
                        try StaticFileWriter(
                            root:
                                remote
                        )

                    throw
                        StaticFileWriterFlowFailure
                            .expectedFailure
                } catch
                    let error
                        as StaticFileWriterError
                {
                    try Expect.equal(
                        error,
                        .nonFileRoot(
                            remote
                                .absoluteString
                        ),
                        "static-writer.non-file-root-rejected"
                    )
                }
            }
        }
}

private func staticWriterFixtureArtifacts()
    -> [StaticTextArtifact]
{
    [
        StaticTextArtifact(
            output:
                StandardPath(
                    [
                        "index.html",
                    ]
                ),
            contents:
                "<!doctype html><html><body>home</body></html>\n"
        ),
        StaticTextArtifact(
            output:
                StandardPath(
                    [
                        "account",
                        "index.html",
                    ]
                ),
            contents:
                "<!doctype html><html><body>account</body></html>\n"
        ),
        StaticTextArtifact(
            output:
                StandardPath(
                    [
                        "assets",
                        "css",
                        "site.css",
                    ]
                ),
            contents:
                ".fixture {\n    display: block;\n}\n"
        ),
    ]
}

private func staticWriterTemporaryRoot(
    _ label:
        String
) -> URL
{
    FileManager
        .default
        .temporaryDirectory
        .appendingPathComponent(
            "constructors-static-writer-\(label)-\(UUID().uuidString)",
            isDirectory:
                true
        )
}

private enum StaticFileWriterFlowFailure:
    Error
{
    case expectedFailure

    case invalidFixtureURL

    case unexpectedWriterError(
        String
    )
}
