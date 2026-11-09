// import HTML
// import CSS
// import JS
// import Path
// import Primitives

// public struct DocumentRenderOptions: Sendable {
//     public let output: StandardPath
//     public let htmlAttributes: HTMLAttribute
//     public let lang: String?
//     public let title: String?
//     public let linkedStylesheets: [String]
//     public let environment: BuildEnvironment
//     public let cssUnreferenced: CSSUnreferenced
//     public let cssIndentStep: Int
//     public let ensureTrailingNewline: Bool

//     public init(
//         output: StandardPath,
//         htmlAttributes: HTMLAttribute = HTMLAttribute(),
//         lang: String? = nil,
//         title: String? = nil,
//         linkedStylesheets: [String] = [],
//         environment: BuildEnvironment,
//         cssUnreferenced: CSSUnreferenced = .commented,
//         cssIndentStep: Int = 4,
//         ensureTrailingNewline: Bool = true
//     ) {
//         self.output = output
//         self.htmlAttributes = htmlAttributes
//         self.lang = lang
//         self.title = title
//         self.linkedStylesheets = linkedStylesheets
//         self.environment = environment
//         self.cssUnreferenced = cssUnreferenced
//         self.cssIndentStep = cssIndentStep
//         self.ensureTrailingNewline = ensureTrailingNewline
//     }
// }

// public func render_self_contained_document(
//     _ input: RenderInput,
//     options: DocumentRenderOptions,
//     onGate: @escaping @Sendable (GateEvent) -> Void = { _ in }
// ) -> RenderOutput {
//     let placedScripts = place_scripts(input.javascript)

//     let inlineCSS: String?
//     if input.stylesheets.isEmpty {
//         inlineCSS = nil
//     } else {
//         let collections = [
//             input.head + placedScripts.head,
//             input.body + placedScripts.body
//         ].filter { !$0.isEmpty }

//         inlineCSS = CSSStyleSheet.renderedMerged(
//             input.stylesheets,
//             forNodeCollections: collections,
//             indentStep: options.cssIndentStep,
//             ensureTrailingNewline: options.ensureTrailingNewline,
//             unreferenced: options.cssUnreferenced
//         )
//     }

//     var htmlAttrs = options.htmlAttributes
//     if let lang = options.lang {
//         htmlAttrs.merge(["lang": lang])
//     }

//     var headNodes: HTMLFragment = [
//         HTML.meta(.charset()),
//         HTML.meta(.viewport())
//     ]

//     if let title = options.title {
//         headNodes.append(
//             HTML.title(title)
//         )
//     }

//     for href in options.linkedStylesheets {
//         headNodes.append(
//             HTML.link(.stylesheet(href: href))
//         )
//     }

//     if let inlineCSS, !inlineCSS.isEmpty {
//         headNodes.append(
//             HTML.style(inlineCSS)
//         )
//     }

//     headNodes += input.head
//     headNodes += placedScripts.head

//     let doc = HTMLDocument(
//         html: htmlAttrs,
//         head: headNodes,
//         body: input.body + placedScripts.body
//     )

//     let html = doc.render(
//         default: .pretty,
//         environment: options.environment,
//         onGate: onGate
//     )

//     return RenderOutput(
//         files: [
//             RenderedFile(
//                 output: options.output,
//                 content: html
//             )
//         ]
//     )
// }

// public struct SplitDocumentRenderOptions: Sendable {
//     public let htmlOutput: StandardPath
//     public let cssOutput: StandardPath
//     public let htmlAttributes: HTMLAttribute
//     public let lang: String?
//     public let title: String?
//     public let stylesheetHref: String
//     public let linkedStylesheets: [String]
//     public let environment: BuildEnvironment
//     public let cssUnreferenced: CSSUnreferenced
//     public let cssIndentStep: Int
//     public let ensureTrailingNewline: Bool

//     public init(
//         htmlOutput: StandardPath,
//         cssOutput: StandardPath,
//         htmlAttributes: HTMLAttribute = HTMLAttribute(),
//         lang: String? = nil,
//         title: String? = nil,
//         stylesheetHref: String,
//         linkedStylesheets: [String] = [],
//         environment: BuildEnvironment,
//         cssUnreferenced: CSSUnreferenced = .commented,
//         cssIndentStep: Int = 4,
//         ensureTrailingNewline: Bool = true
//     ) {
//         self.htmlOutput = htmlOutput
//         self.cssOutput = cssOutput
//         self.htmlAttributes = htmlAttributes
//         self.lang = lang
//         self.title = title
//         self.stylesheetHref = stylesheetHref
//         self.linkedStylesheets = linkedStylesheets
//         self.environment = environment
//         self.cssUnreferenced = cssUnreferenced
//         self.cssIndentStep = cssIndentStep
//         self.ensureTrailingNewline = ensureTrailingNewline
//     }
// }

// public func render_split_document(
//     _ input: RenderInput,
//     options: SplitDocumentRenderOptions,
//     onGate: @escaping @Sendable (GateEvent) -> Void = { _ in }
// ) -> RenderOutput {
//     let placedScripts = place_scripts(input.javascript)

//     var htmlAttrs = options.htmlAttributes
//     if let lang = options.lang {
//         htmlAttrs.merge(["lang": lang])
//     }

//     var headNodes: HTMLFragment = [
//         HTML.meta(.charset()),
//         HTML.meta(.viewport())
//     ]

//     if let title = options.title {
//         headNodes.append(
//             HTML.title(title)
//         )
//     }

//     for href in options.linkedStylesheets {
//         headNodes.append(
//             HTML.link(.stylesheet(href: href))
//         )
//     }

//     headNodes.append(
//         HTML.link(.stylesheet(href: options.stylesheetHref))
//     )

//     headNodes += input.head
//     headNodes += placedScripts.head

//     let doc = HTMLDocument(
//         html: htmlAttrs,
//         head: headNodes,
//         body: input.body + placedScripts.body
//     )

//     let html = doc.render(
//         default: .pretty,
//         environment: options.environment,
//         onGate: onGate
//     )

//     let css = input.stylesheets.isEmpty
//         ? ""
//         : CSSStyleSheet.merged(input.stylesheets).rendered(
//             forDocuments: [doc],
//             indentStep: options.cssIndentStep,
//             ensureTrailingNewline: options.ensureTrailingNewline,
//             unreferenced: options.cssUnreferenced
//         )

//     return RenderOutput(
//         files: [
//             RenderedFile(
//                 output: options.htmlOutput,
//                 content: html
//             ),
//             RenderedFile(
//                 output: options.cssOutput,
//                 content: css
//             )
//         ]
//     )
// }

// public struct FragmentRenderOptions: Sendable {
//     public let output: StandardPath

//     public init(
//         output: StandardPath
//     ) {
//         self.output = output
//     }
// }

// public func render_fragment(
//     _ input: RenderInput,
//     options: FragmentRenderOptions
// ) -> RenderOutput {
//     let placedScripts = place_scripts(input.javascript)
//     let fragment = (input.body + placedScripts.body).snippet()

//     return RenderOutput(
//         files: [
//             RenderedFile(
//                 output: options.output,
//                 content: fragment
//             )
//         ]
//     )
// }
