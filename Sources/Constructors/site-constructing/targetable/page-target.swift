import HTML
import CSS
import JS
import Path
import Primitives

public struct PageTarget: Targetable, MetadataTargetable {
    public let html: @Sendable () throws -> HTMLDocument
    private let _htmlForEnvironment: (@Sendable (BuildEnvironment) throws -> HTMLDocument)?

    public let output: StandardPath
    public let visibility: Set<BuildEnvironment>
    public let navigation: NavigationSetting

    public let metadata: TargetMetadata

    public init(
        html: @Sendable @escaping () throws -> HTMLDocument,
        output: StandardPath,
        visibility: Set<BuildEnvironment> = [.local, .test, .public],
        navigation: NavigationSetting = .none,
        metadata: TargetMetadata? = nil
    ) {
        self.html = html
        self._htmlForEnvironment = nil
        self.output = output
        self.visibility = visibility
        self.navigation = navigation
        self.metadata =
            metadata.exists_or_inits(visibility: visibility)
    }

    @available(
        *,
        deprecated,
        message: """
        Use the throwing PageTarget initializer so page-construction failures can propagate through the render pipeline. For an otherwise nonthrowing builder, explicitly type the closure as () throws -> HTMLDocument when migrating.
        """
    )
    public init(
        html: @Sendable @escaping () -> HTMLDocument,
        output: StandardPath,
        visibility: Set<BuildEnvironment> = [.local, .test, .public],
        navigation: NavigationSetting = .none,
        metadata: TargetMetadata? = nil
    ) {
        self.html = html
        self._htmlForEnvironment = nil
        self.output = output
        self.visibility = visibility
        self.navigation = navigation
        self.metadata =
            metadata.exists_or_inits(visibility: visibility)
    }

    /// Explicitly selects the document before HTML serialization.
    /// Existing environment-independent pages continue to use their original builder.
    public func document(in environment: BuildEnvironment) throws -> HTMLDocument {
        if let _htmlForEnvironment {
            return try _htmlForEnvironment(environment)
        }
        return try html()
    }

    public init(
        htmlForEnvironment: @Sendable @escaping (BuildEnvironment) throws -> HTMLDocument,
        output: StandardPath,
        visibility: Set<BuildEnvironment> = [.local, .test, .public],
        navigation: NavigationSetting = .none,
        metadata: TargetMetadata? = nil
    ) {
        self.html = {
            throw PageTargetError.environmentRequired
        }
        self._htmlForEnvironment = htmlForEnvironment
        self.output = output
        self.visibility = visibility
        self.navigation = navigation
        self.metadata = metadata.exists_or_inits(visibility: visibility)
    }

    /// Retained for existing environment-independent clients.
    /// Environment-sensitive targets require `document(in:)`.
    public func document() throws -> HTMLDocument {
        try html()
    }
}

public enum PageTargetError: Error, Sendable {
    case environmentRequired
}

// public extension PageTarget {
//     init(
//         artifact: @Sendable @escaping () -> RenderArtifact,
//         output: StandardPath,
//         visibility: Set<BuildEnvironment> = [.local, .test, .public],
//         navigation: NavigationSetting = .none,
//         metadata: TargetMetadata? = nil,
//         lang: String? = nil,
//         title: String? = nil,
//         linkedStylesheets: [String] = [],
//         inlineComponentCSS: Bool = false,
//         componentCSSUnreferenced: CSSUnreferenced = .commented
//     ) {
//         self.init(
//             html: {
//                 let built = artifact()
//                 let placedScripts = place_scripts(built.scripts)

//                 let inlineCSS: String?
//                 if inlineComponentCSS && !built.stylesheets.isEmpty {
//                     let collections = [
//                         built.head + placedScripts.head,
//                         built.html + placedScripts.body
//                     ].filter { !$0.isEmpty }

//                     inlineCSS = CSSStyleSheet.renderedMerged(
//                         built.stylesheets,
//                         forNodeCollections: collections,
//                         indentStep: 4,
//                         ensureTrailingNewline: true,
//                         unreferenced: componentCSSUnreferenced
//                     )
//                 } else {
//                     inlineCSS = nil
//                 }

//                 var htmlAttrs = HTMLAttribute()
//                 if let lang {
//                     htmlAttrs.merge(["lang": lang])
//                 }

//                 var headNodes: HTMLFragment = [
//                     HTML.meta(.charset()),
//                     HTML.meta(.viewport())
//                 ]

//                 if let title {
//                     headNodes.append(
//                         HTML.title(title)
//                     )
//                 }

//                 for href in linkedStylesheets {
//                     headNodes.append(
//                         HTML.link(.stylesheet(href: href))
//                     )
//                 }

//                 if let inlineCSS, !inlineCSS.isEmpty {
//                     headNodes.append(
//                         HTML.style(inlineCSS)
//                     )
//                 }

//                 headNodes += built.head
//                 headNodes += placedScripts.head

//                 return HTML.document(
//                     html: htmlAttrs,
//                     head: headNodes,
//                     body: built.html + placedScripts.body
//                 )
//             },
//             output: output,
//             visibility: visibility,
//             navigation: navigation,
//             metadata: metadata
//         )
//     }

//     func artifact() -> RenderArtifact {
//         let doc = html()

//         return RenderArtifact(
//             head: doc.head,
//             html: doc.body,
//             scripts: [],
//             stylesheets: []
//         )
//     }
// }
