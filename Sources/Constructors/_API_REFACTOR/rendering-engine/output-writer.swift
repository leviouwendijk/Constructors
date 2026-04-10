import Foundation

public struct OutputWriter {
    public let context: BuildContext

    public init(
        context: BuildContext
    ) {
        self.context = context
    }

    public func write(
        _ output: RenderOutput
    ) throws {
        for file in output.files {
            let outURL = file.output.url(base: context.baseURL)

            do {
                try FileManager.default.createDirectory(
                    at: outURL.deletingLastPathComponent(),
                    withIntermediateDirectories: true
                )
            } catch {
                throw RenderingError.createDirFailed(
                    url: outURL.deletingLastPathComponent(),
                    underlying: error
                )
            }

            do {
                try context.env.write(
                    content: file.content,
                    to: outURL
                )
            } catch {
                throw RenderingError.writeFailed(
                    url: outURL,
                    underlying: error
                )
            }
        }
    }

    public func write(
        _ export: EvaluatedBundleExport
    ) throws {
        guard export.route != nil || !export.additional_files.isEmpty else {
            return
        }

        try write(export.output)
    }

    public func write(
        _ exports: EvaluatedExportSet
    ) throws {
        try write(exports.output)
    }
}
