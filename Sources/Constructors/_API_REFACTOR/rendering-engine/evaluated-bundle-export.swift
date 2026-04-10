import Path
import Primitives

public enum HTMLExportKind: Sendable, Equatable {
    case document
    case fragment
}

public enum BundleExportKind: Sendable, Equatable {
    case html(HTMLExportKind)
    case stylesheet
    case javascript
}

public struct BundleExportRoute: Sendable, Equatable {
    public let output: StandardPath
    public let visibility: Set<BuildEnvironment>
    public let metadata: TargetMetadata?

    public init(
        output: StandardPath,
        visibility: Set<BuildEnvironment> = [.local, .test, .public],
        metadata: TargetMetadata? = nil
    ) {
        self.output = output
        self.visibility = visibility
        self.metadata = metadata
    }
}

public struct MetadataRoute: Sendable, Equatable {
    public let output: StandardPath
    public let visibility: Set<BuildEnvironment>
    public let metadata: TargetMetadata

    public init(
        output: StandardPath,
        visibility: Set<BuildEnvironment>,
        metadata: TargetMetadata
    ) {
        self.output = output
        self.visibility = visibility
        self.metadata = metadata
    }
}

public struct EvaluatedBundleExport: Sendable {
    public let id: String?
    public let kind: BundleExportKind
    public let bundle: RenderBundle
    public let content: String
    public let additional_files: [RenderedFile]
    public let route: BundleExportRoute?
    public let metadata: TargetMetadata?
    public let visibility: Set<BuildEnvironment>
    public let metadata_route: MetadataRoute?

    public init(
        id: String? = nil,
        kind: BundleExportKind,
        bundle: RenderBundle,
        content: String,
        additional_files: [RenderedFile] = [],
        route: BundleExportRoute? = nil,
        metadata: TargetMetadata? = nil,
        visibility: Set<BuildEnvironment> = [.local, .test, .public],
        metadata_route: MetadataRoute? = nil
    ) {
        self.id = id
        self.kind = kind
        self.bundle = bundle
        self.content = content
        self.additional_files = additional_files
        self.route = route
        self.metadata = metadata
        self.visibility = visibility
        self.metadata_route = metadata_route
    }

    public var primaryFile: RenderedFile? {
        guard let route else {
            return nil
        }

        return RenderedFile(
            output: route.output,
            content: content
        )
    }

    public var files: [RenderedFile] {
        if let primaryFile {
            return [primaryFile] + additional_files
        } else {
            return additional_files
        }
    }

    public var output: RenderOutput {
        RenderOutput(files: files)
    }

    public func identified(
        _ id: String
    ) -> EvaluatedBundleExport {
        EvaluatedBundleExport(
            id: id,
            kind: kind,
            bundle: bundle,
            content: content,
            additional_files: additional_files,
            route: route,
            metadata: metadata,
            visibility: visibility,
            metadata_route: metadata_route
        )
    }

    public func withMetadata(
        _ metadata: TargetMetadata?
    ) -> EvaluatedBundleExport {
        let resolvedVisibility = route?.visibility ?? visibility

        let resolvedRoute = route.map {
            BundleExportRoute(
                output: $0.output,
                visibility: $0.visibility,
                metadata: metadata ?? $0.metadata
            )
        }

        let resolvedMetadataRoute: MetadataRoute? = {
            if let existing = metadata_route {
                return MetadataRoute(
                    output: existing.output,
                    visibility: existing.visibility,
                    metadata: metadata ?? existing.metadata
                )
            }

            guard
                let route = resolvedRoute,
                let routeMetadata = route.metadata,
                kind == .html(.document)
            else {
                return nil
            }

            return MetadataRoute(
                output: route.output,
                visibility: resolvedVisibility,
                metadata: routeMetadata
            )
        }()

        return EvaluatedBundleExport(
            id: id,
            kind: kind,
            bundle: bundle,
            content: content,
            additional_files: additional_files,
            route: resolvedRoute,
            metadata: metadata,
            visibility: visibility,
            metadata_route: resolvedMetadataRoute
        )
    }

    public func withVisibility(
        _ visibility: Set<BuildEnvironment>
    ) -> EvaluatedBundleExport {
        let resolvedRoute = route.map {
            BundleExportRoute(
                output: $0.output,
                visibility: visibility,
                metadata: $0.metadata
            )
        }

        let resolvedMetadataRoute = metadata_route.map {
            MetadataRoute(
                output: $0.output,
                visibility: visibility,
                metadata: $0.metadata
            )
        }

        return EvaluatedBundleExport(
            id: id,
            kind: kind,
            bundle: bundle,
            content: content,
            additional_files: additional_files,
            route: resolvedRoute,
            metadata: metadata,
            visibility: visibility,
            metadata_route: resolvedMetadataRoute
        )
    }

    public func withRoute(
        _ route: BundleExportRoute?
    ) -> EvaluatedBundleExport {
        let resolvedMetadataRoute: MetadataRoute? = {
            guard
                kind == .html(.document),
                let route,
                let metadata = route.metadata
            else {
                return nil
            }

            return MetadataRoute(
                output: route.output,
                visibility: route.visibility,
                metadata: metadata
            )
        }()

        return EvaluatedBundleExport(
            id: id,
            kind: kind,
            bundle: bundle,
            content: content,
            additional_files: additional_files,
            route: route,
            metadata: metadata,
            visibility: visibility,
            metadata_route: resolvedMetadataRoute
        )
    }

    public func withMetadataRoute(
        _ route: MetadataRoute?
    ) -> EvaluatedBundleExport {
        EvaluatedBundleExport(
            id: id,
            kind: kind,
            bundle: bundle,
            content: content,
            additional_files: additional_files,
            route: route == nil ? self.route : self.route,
            metadata: metadata,
            visibility: visibility,
            metadata_route: route
        )
    }
}

public struct EvaluatedExportSet: Sendable {
    public let exports: [EvaluatedBundleExport]

    public init(
        _ exports: [EvaluatedBundleExport]
    ) {
        self.exports = exports
    }

    public subscript(
        id: String
    ) -> EvaluatedBundleExport? {
        exports.first { $0.id == id }
    }

    public var files: [RenderedFile] {
        exports.flatMap(\.files)
    }

    public var output: RenderOutput {
        RenderOutput(files: files)
    }

    public var metadata_routes: [MetadataRoute] {
        exports.compactMap(\.metadata_route)
    }

    public func ofKind(
        _ kind: BundleExportKind
    ) -> [EvaluatedBundleExport] {
        exports.filter { $0.kind == kind }
    }
}
