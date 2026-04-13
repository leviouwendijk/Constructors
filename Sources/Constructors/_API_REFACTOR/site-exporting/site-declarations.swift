import Path
import Primitives

public protocol DeclarationIdentifier: RawRepresentable, Hashable, Sendable where RawValue == String {}

public struct _EmptyDeclarationIdentifiers: DeclarationIdentifier {
    public let rawValue: String

    public init?(
        rawValue: String
    ) {
        self.rawValue = rawValue
    }
}

public typealias SiteDeclaration<Site: SiteDeclaring> = Declarations<
    Site.DocumentIdentifier,
    Site.StyleIdentifier,
    Site.SnippetIdentifier
>

public struct Declarations<
    DocumentIdentifier: DeclarationIdentifier,
    StyleIdentifier: DeclarationIdentifier,
    SnippetIdentifier: DeclarationIdentifier
>: Sendable {
    public let documents: [DocumentIdentifier: DocumentDeclaration<DocumentIdentifier>]
    public let styles: [StyleIdentifier: StyleDeclaration<StyleIdentifier>]
    public let snippets: [SnippetIdentifier: SnippetDeclaration<SnippetIdentifier>]

    public init(
        documents: [DocumentIdentifier: DocumentDeclaration<DocumentIdentifier>] = [:],
        styles: [StyleIdentifier: StyleDeclaration<StyleIdentifier>] = [:],
        snippets: [SnippetIdentifier: SnippetDeclaration<SnippetIdentifier>] = [:]
    ) {
        self.documents = documents
        self.styles = styles
        self.snippets = snippets
    }
}

public struct DocumentDeclaration<Identifier: DeclarationIdentifier>: Sendable {
    public let id: Identifier
    public let navigation: NavigationSetting
    public let export: BundleExportDefinition

    public init(
        id: Identifier,
        navigation: NavigationSetting = .none,
        export: BundleExportDefinition
    ) {
        self.id = id
        self.navigation = navigation
        self.export = export
    }

    public init(
        id: Identifier,
        route: BundleExportRoute,
        navigation: NavigationSetting = .none,
        evaluate: @escaping @Sendable (BuildContext, any SiteReferenceResolving) throws -> EvaluatedBundleExport
    ) {
        self.id = id
        self.navigation = navigation
        self.export = BundleExportDefinition(
            id: .document(id.rawValue),
            route: route,
            evaluate: evaluate
        )
    }

    public init(
        id: Identifier,
        route: BundleExportRoute,
        navigation: NavigationSetting = .none,
        options: @escaping @Sendable (
            BuildContext,
            any SiteReferenceResolving
        ) throws -> DocumentEvaluationOptions = { _, _ in .default },
        build: @escaping @Sendable (
            any SiteReferenceResolving
        ) throws -> RenderBundle
    ) {
        self.init(
            id: id,
            route: route,
            navigation: navigation
        ) { context, references in
            let documentOptions = try options(
                context,
                references
            )

            return documentOptions.evaluate(
                try build(
                    references
                ),
                route: route,
                environment: context.env
            )
        }
    }

    public var route: BundleExportRoute {
        guard let route = export.route else {
            preconditionFailure(
                "DocumentDeclaration requires an export route."
            )
        }

        return route
    }

    public var output: StandardPath {
        route.output
    }

    public var visibility: Set<BuildEnvironment> {
        export.visibility
    }

    public var metadata: TargetMetadata? {
        export.metadata
    }
}

public struct StyleDeclaration<Identifier: DeclarationIdentifier>: Sendable {
    public let id: Identifier
    public let export: BundleExportDefinition

    public init(
        id: Identifier,
        export: BundleExportDefinition
    ) {
        self.id = id
        self.export = export
    }

    public init(
        id: Identifier,
        route: BundleExportRoute,
        evaluate: @escaping @Sendable (
            BuildContext,
            any SiteReferenceResolving
        ) throws -> EvaluatedBundleExport
    ) {
        self.id = id
        self.export = BundleExportDefinition(
            id: .stylesheet(id.rawValue),
            route: route,
            evaluate: evaluate
        )
    }

    public var route: BundleExportRoute {
        guard let route = export.route else {
            preconditionFailure(
                "StyleDeclaration requires an export route."
            )
        }

        return route
    }

    public var output: StandardPath {
        route.output
    }

    public var visibility: Set<BuildEnvironment> {
        export.visibility
    }

    public var metadata: TargetMetadata? {
        export.metadata
    }
}

public struct SnippetDeclaration<Identifier: DeclarationIdentifier>: Sendable {
    public let id: Identifier
    public let export: BundleExportDefinition

    public init(
        id: Identifier,
        export: BundleExportDefinition
    ) {
        self.id = id
        self.export = export
    }

    public init(
        id: Identifier,
        route: BundleExportRoute,
        evaluate: @escaping @Sendable (
            BuildContext,
            any SiteReferenceResolving
        ) throws -> EvaluatedBundleExport
    ) {
        self.id = id
        self.export = BundleExportDefinition(
            id: .snippet(id.rawValue),
            route: route,
            evaluate: evaluate
        )
    }

    public var route: BundleExportRoute {
        guard let route = export.route else {
            preconditionFailure(
                "SnippetDeclaration requires an export route."
            )
        }

        return route
    }

    public var output: StandardPath {
        route.output
    }

    public var visibility: Set<BuildEnvironment> {
        export.visibility
    }

    public var metadata: TargetMetadata? {
        export.metadata
    }
}

public protocol SiteDeclaring: SiteObject {
    associatedtype DocumentIdentifier: DeclarationIdentifier = _EmptyDeclarationIdentifiers
    associatedtype StyleIdentifier: DeclarationIdentifier = _EmptyDeclarationIdentifiers
    associatedtype SnippetIdentifier: DeclarationIdentifier = _EmptyDeclarationIdentifiers

    static func declarations() throws -> Declarations<
        DocumentIdentifier,
        StyleIdentifier,
        SnippetIdentifier
    >

    static func declaration_exports() throws -> [BundleExportDefinition]
}

public extension SiteDeclaring {
    static func declarations() throws -> Declarations<
        DocumentIdentifier,
        StyleIdentifier,
        SnippetIdentifier
    > {
        Declarations()
    }

    static func declaration_exports() throws -> [BundleExportDefinition] {
        let siteDeclarations = try declarations()

        let documents = siteDeclarations.documents
            .keys
            .sorted { $0.rawValue < $1.rawValue }
            .compactMap { key in
                siteDeclarations.documents[key]?.export
            }

        let styles = siteDeclarations.styles
            .keys
            .sorted { $0.rawValue < $1.rawValue }
            .compactMap { key in
                siteDeclarations.styles[key]?.export
            }

        let snippets = siteDeclarations.snippets
            .keys
            .sorted { $0.rawValue < $1.rawValue }
            .compactMap { key in
                siteDeclarations.snippets[key]?.export
            }

        return documents + styles + snippets
    }
}
