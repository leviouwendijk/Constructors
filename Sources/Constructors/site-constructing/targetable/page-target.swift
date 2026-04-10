import HTML
import CSS
import JS
import Path
import Primitives

public struct PageTarget: Targetable, MetadataTargetable {
    public let html: @Sendable () -> HTMLDocument

    public let output: StandardPath
    public let visibility: Set<BuildEnvironment>
    public let navigation: NavigationSetting

    public let metadata: TargetMetadata

    public init(
        html: @Sendable @escaping () -> HTMLDocument,
        output: StandardPath,
        visibility: Set<BuildEnvironment> = [.local, .test, .public],
        navigation: NavigationSetting = .none,
        metadata: TargetMetadata? = nil
    ) {
        self.html = html
        self.output = output
        self.visibility = visibility
        self.navigation = navigation
        self.metadata =
            metadata.exists_or_inits(visibility: visibility)
    }

    public func document() -> HTMLDocument {
        html()
    }
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
