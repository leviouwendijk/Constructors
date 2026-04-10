// import CSS
// import Path

// public struct ArtifactCSSRenderOptions: Sendable, Equatable {
//     public var unreferenced: CSSUnreferenced
//     public var ensureTrailingNewline: Bool
//     public var indentStep: Int

//     public init(
//         unreferenced: CSSUnreferenced = .commented,
//         ensureTrailingNewline: Bool = true,
//         indentStep: Int = 4
//     ) {
//         self.unreferenced = unreferenced
//         self.ensureTrailingNewline = ensureTrailingNewline
//         self.indentStep = indentStep
//     }
// }

// public extension ArtifactCSSRenderOptions {
//     static let inline_document_default = ArtifactCSSRenderOptions(
//         unreferenced: .commented,
//         ensureTrailingNewline: true,
//         indentStep: 4
//     )

//     static let external_document_default = ArtifactCSSRenderOptions(
//         unreferenced: .commented,
//         ensureTrailingNewline: true,
//         indentStep: 4
//     )
// }

// public protocol ArtifactCSSDocumentOptions: Sendable {
//     var linkedStylesheets: [String] { get }
//     var renderOptions: ArtifactCSSRenderOptions { get }
// }

// public struct ArtifactInlineCSSDocumentOptions: ArtifactCSSDocumentOptions, Sendable, Equatable {
//     public var linkedStylesheets: [String]
//     public var renderOptions: ArtifactCSSRenderOptions

//     public init(
//         linkedStylesheets: [String] = [],
//         renderOptions: ArtifactCSSRenderOptions = .inline_document_default
//     ) {
//         self.linkedStylesheets = linkedStylesheets
//         self.renderOptions = renderOptions
//     }
// }

// public struct ArtifactExternalCSSFileOptions: Sendable, Equatable {
//     public var output: GenericPath
//     public var href: String?

//     public init(
//         output: GenericPath,
//         href: String? = nil
//     ) {
//         self.output = output
//         self.href = href
//     }
// }

// public struct ArtifactExternalCSSDocumentOptions: ArtifactCSSDocumentOptions, Sendable, Equatable {
//     public var css: ArtifactExternalCSSFileOptions
//     public var linkedStylesheets: [String]
//     public var renderOptions: ArtifactCSSRenderOptions

//     public init(
//         css: ArtifactExternalCSSFileOptions,
//         linkedStylesheets: [String] = [],
//         renderOptions: ArtifactCSSRenderOptions = .external_document_default
//     ) {
//         self.css = css
//         self.linkedStylesheets = linkedStylesheets
//         self.renderOptions = renderOptions
//     }
// }

// public enum ArtifactDocumentStyle: Sendable, Equatable {
//     case linked(stylesheets: [String])
//     case inline(ArtifactInlineCSSDocumentOptions)
//     case external(ArtifactExternalCSSDocumentOptions)
// }

// public extension ArtifactDocumentStyle {
//     static func linked(
//         _ stylesheets: [String] = []
//     ) -> Self {
//         .linked(stylesheets: stylesheets)
//     }

//     static func inline(
//         _ options: ArtifactInlineCSSDocumentOptions = .init()
//     ) -> Self {
//         .inline(options)
//     }

//     static func external(
//         _ options: ArtifactExternalCSSDocumentOptions
//     ) -> Self {
//         .external(options)
//     }
// }

// public struct ArtifactDocumentEmission: Sendable, Equatable {
//     public var lang: String?
//     public var title: String?
//     public var style: ArtifactDocumentStyle

//     public init(
//         lang: String? = nil,
//         title: String? = nil,
//         style: ArtifactDocumentStyle = .linked()
//     ) {
//         self.lang = lang
//         self.title = title
//         self.style = style
//     }
// }

// public extension ArtifactDocumentEmission {
//     static func linked(
//         lang: String? = nil,
//         title: String? = nil,
//         stylesheets: [String] = []
//     ) -> Self {
//         .init(
//             lang: lang,
//             title: title,
//             style: .linked(stylesheets)
//         )
//     }

//     static func inline(
//         lang: String? = nil,
//         title: String? = nil,
//         options: ArtifactInlineCSSDocumentOptions = .init()
//     ) -> Self {
//         .init(
//             lang: lang,
//             title: title,
//             style: .inline(options)
//         )
//     }

//     static func external(
//         lang: String? = nil,
//         title: String? = nil,
//         options: ArtifactExternalCSSDocumentOptions
//     ) -> Self {
//         .init(
//             lang: lang,
//             title: title,
//             style: .external(options)
//         )
//     }
// }

// public struct EmittedCSSFile: Sendable {
//     public let output: GenericPath
//     public let content: String

//     public init(
//         output: GenericPath,
//         content: String
//     ) {
//         self.output = output
//         self.content = content
//     }
// }
