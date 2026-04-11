import Foundation
import Primitives
import Path
import HTML
import CSS
import JS

public struct SnippetTargets: Targetable, MetadataTargetable {
    public enum Mode: Sendable {
        case inline
        case external(cssPath: StandardPath)
        case fragment
    }

    public let html: HTMLFragment
    public let javascript: [JSScript]
    public let stylesheets: [CSSStyleSheet]
    public let htmlOutput: StandardPath
    public let mode: Mode
    public let visibility: Set<BuildEnvironment>

    public var suffix: String = "snippets"

    public var output: StandardPath {
        var comps: [String] = []
        comps.append(suffix)

        if let s = sorting_category {
            comps.append(s.rawValue)
        }

        return StandardPath(comps).merged(appending: htmlOutput)
    }

    public enum SortingCategory: String, Sendable {
        case asset
        case document
    }

    public let sorting_category: SortingCategory?
    public let metadata: TargetMetadata

    public init(
        html: HTMLFragment,
        javascript: [JSScript] = [],
        stylesheets: [CSSStyleSheet],
        htmlOutput: StandardPath,
        mode: Mode,
        visibility: Set<BuildEnvironment> = [.local],
        sorting_category: SortingCategory? = nil,
        metadata: TargetMetadata? = nil
    ) {
        self.html = html
        self.javascript = javascript
        self.stylesheets = stylesheets
        self.htmlOutput = htmlOutput
        self.mode = mode
        self.visibility = visibility
        self.sorting_category = sorting_category
        self.metadata = metadata ?? .blocked
    }

    public static func doc_inline_css(
        html: HTMLFragment,
        javascript: [JSScript] = [],
        stylesheets: [CSSStyleSheet],
        htmlOutput: StandardPath,
        visibility: Set<BuildEnvironment> = [.local],
        sorting_category: SortingCategory? = .document
    ) -> SnippetTargets {
        SnippetTargets(
            html: html,
            javascript: javascript,
            stylesheets: stylesheets,
            htmlOutput: htmlOutput,
            mode: .inline,
            visibility: visibility,
            sorting_category: sorting_category
        )
    }

    public static func doc_external_css(
        html: HTMLFragment,
        javascript: [JSScript] = [],
        stylesheets: [CSSStyleSheet],
        htmlOutput: StandardPath,
        cssOutput: StandardPath,
        visibility: Set<BuildEnvironment> = [.local],
        sorting_category: SortingCategory? = .document
    ) -> SnippetTargets {
        SnippetTargets(
            html: html,
            javascript: javascript,
            stylesheets: stylesheets,
            htmlOutput: htmlOutput,
            mode: .external(cssPath: cssOutput),
            visibility: visibility,
            sorting_category: sorting_category
        )
    }

    public static func html_fragment(
        html: HTMLFragment,
        javascript: [JSScript] = [],
        output: StandardPath,
        visibility: Set<BuildEnvironment> = [.local, .test],
        sorting_category: SortingCategory? = .asset
    ) -> SnippetTargets {
        SnippetTargets(
            html: html,
            javascript: javascript,
            stylesheets: [],
            htmlOutput: output,
            mode: .fragment,
            visibility: visibility,
            sorting_category: sorting_category
        )
    }

    @inlinable
    public func isVisible(in environment: BuildEnvironment) -> Bool {
        visibility.contains(environment)
    }

    @inlinable
    public var htmlDocument: HTMLDocument {
        let placed = place_scripts(javascript)
        return HTML.document(
            head: placed.head,
            body: html + placed.body
        )
    }

    public func url(
        base_url: URL
    ) -> URL {
        var url = base_url
            .appendingPathComponent(suffix)

        if let cat = sorting_category {
            url = url.appendingPathComponent(cat.rawValue)
        }

        return url
    }
}

internal func renderInlineHTML(
    fragment: HTMLFragment,
    scripts: [JSScript] = [],
    sheets: [CSSStyleSheet],
    env: BuildEnvironment,
    onGate: @escaping @Sendable (GateEvent) -> Void = { _ in }
) -> String {
    let placedScripts = place_scripts(scripts)

    let inlineCSS: String?
    if sheets.isEmpty {
        inlineCSS = nil
    } else {
        inlineCSS = CSSStyleSheet.renderedMerged(
            sheets,
            forNodeCollections: [
                fragment + placedScripts.body,
                placedScripts.head
            ].filter { !$0.isEmpty },
            indentStep: 4,
            ensureTrailingNewline: true,
            unreferenced: .commented
        )
    }

    let doc = HTMLDocument.basic(
        lang: nil,
        title: nil,
        stylesheets: [],
        inlineStyle: inlineCSS
    ) {
        placedScripts.head + fragment + placedScripts.body
    }

    return doc.render(
        default: .pretty,
        environment: env,
        onGate: onGate
    )
}

// public extension SnippetTargets {
//     init(
//         artifact: RenderArtifact,
//         htmlOutput: StandardPath,
//         mode: Mode,
//         visibility: Set<BuildEnvironment> = [.local],
//         sorting_category: SortingCategory? = nil,
//         metadata: TargetMetadata? = nil
//     ) {
//         self.init(
//             html: artifact.html,
//             javascript: artifact.scripts,
//             stylesheets: artifact.stylesheets,
//             htmlOutput: htmlOutput,
//             mode: mode,
//             visibility: visibility,
//             sorting_category: sorting_category,
//             metadata: metadata
//         )
//     }

//     static func doc_inline_css(
//         artifact: RenderArtifact,
//         htmlOutput: StandardPath,
//         visibility: Set<BuildEnvironment> = [.local],
//         sorting_category: SortingCategory? = .document
//     ) -> SnippetTargets {
//         SnippetTargets(
//             artifact: artifact,
//             htmlOutput: htmlOutput,
//             mode: .inline,
//             visibility: visibility,
//             sorting_category: sorting_category
//         )
//     }

//     static func doc_external_css(
//         artifact: RenderArtifact,
//         htmlOutput: StandardPath,
//         cssOutput: StandardPath,
//         visibility: Set<BuildEnvironment> = [.local],
//         sorting_category: SortingCategory? = .document
//     ) -> SnippetTargets {
//         SnippetTargets(
//             artifact: artifact,
//             htmlOutput: htmlOutput,
//             mode: .external(cssPath: cssOutput),
//             visibility: visibility,
//             sorting_category: sorting_category
//         )
//     }

//     static func html_fragment(
//         artifact: RenderArtifact,
//         output: StandardPath,
//         visibility: Set<BuildEnvironment> = [.local, .test],
//         sorting_category: SortingCategory? = .asset
//     ) -> SnippetTargets {
//         SnippetTargets(
//             html: artifact.html,
//             javascript: artifact.scripts,
//             stylesheets: [],
//             htmlOutput: output,
//             mode: .fragment,
//             visibility: visibility,
//             sorting_category: sorting_category
//         )
//     }

//     var artifact: RenderArtifact {
//         RenderArtifact(
//             html: html,
//             scripts: javascript,
//             stylesheets: stylesheets
//         )
//     }

//     var css_bundle: CSSBundle {
//         CSSBundle(stylesheets)
//     }
// }
