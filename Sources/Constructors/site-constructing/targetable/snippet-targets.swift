import Foundation
import Primitives
import Path
import HTML
import CSS

public struct SnippetTargets: Targetable, MetadataTargetable {
    public enum Mode: Sendable {
        case inline
        case external(cssPath: GenericPath)
        case fragment
    }

    public let html: HTMLFragment
    public let stylesheets: [CSSStyleSheet]
    public let htmlOutput: GenericPath
    public let mode: Mode // render css this way
    public let visibility: Set<BuildEnvironment>

    public var suffix: String = "snippets"

    public var output: GenericPath {
        var comps: [String] = []
        comps.append(suffix) // append 'snippets' dir

        if let s = sorting_category {
            comps.append(s.rawValue) // optional subcategory
        }

        // return htmlOutput.merged(appending: GenericPath(comps))
        return GenericPath(comps).merged(appending: htmlOutput)
    }

    public enum SortingCategory: String, Sendable {
        case asset
        case document
    }
    public let sorting_category: SortingCategory? 
    public let metadata: TargetMetadata

    public init(
        html: HTMLFragment,
        stylesheets: [CSSStyleSheet],
        htmlOutput: GenericPath,
        mode: Mode,
        visibility: Set<BuildEnvironment> = [.local],
        sorting_category: SortingCategory? = nil,
        metadata: TargetMetadata? = nil
    ) {
        self.html = html
        self.stylesheets = stylesheets
        self.htmlOutput = htmlOutput
        self.mode = mode
        self.visibility = visibility
        self.sorting_category = sorting_category
        // self.metadata = metadata
        self.metadata = metadata ?? .blocked
    }

    /// Renders CSS inline
    public static func doc_inline_css(
        html: HTMLFragment,
        stylesheets: [CSSStyleSheet],
        htmlOutput: GenericPath,
        visibility: Set<BuildEnvironment> = [.local],
        sorting_category: SortingCategory? = .document
    ) -> SnippetTargets {
        SnippetTargets(
            html: html,
            stylesheets: stylesheets,
            htmlOutput: htmlOutput,
            mode: .inline,
            visibility: visibility,
            sorting_category: sorting_category
        )
    }

    /// Renders CSS as separate file
    public static func doc_external_css(
        html: HTMLFragment,
        stylesheets: [CSSStyleSheet],
        htmlOutput: GenericPath,
        cssOutput: GenericPath,
        visibility: Set<BuildEnvironment> = [.local],
        sorting_category: SortingCategory? = .document
    ) -> SnippetTargets {
        SnippetTargets(
            html: html,
            stylesheets: stylesheets,
            htmlOutput: htmlOutput,
            mode: .external(cssPath: cssOutput),
            visibility: visibility,
            sorting_category: sorting_category
        )
    }

    /// DOES NOT accept CSS
    /// Is for public side snippets
    /// requires manual inclusion for conscious publication
    public static func html_fragment(
        html: HTMLFragment,
        output: GenericPath,
        visibility: Set<BuildEnvironment> = [.local, .test],
        sorting_category: SortingCategory? = .asset
    ) -> SnippetTargets {
        SnippetTargets(
            html: html,
            stylesheets: [],
            htmlOutput: output,
            mode: .fragment,
            visibility: visibility,
            sorting_category: sorting_category
        )
    }

    // MARK: - Helpers

    @inlinable
    public func isVisible(in environment: BuildEnvironment) -> Bool {
        visibility.contains(environment)
    }

    // @inlinable
    // public var htmlFragment: HTMLFragment {
    //     html
    // }

    @inlinable
    public var htmlDocument: HTMLDocument {
        html.htmlDocument
    }

    // struct URL: Sendable {
    //     public let base: URL
    //     public var suffix: String
    // }

    public func url(
        base_url: URL,
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
    sheets: [CSSStyleSheet],
    env: BuildEnvironment,
    onGate: @escaping @Sendable (GateEvent) -> Void = { _ in }
) -> String {
    // If there are styles, merge + prune them against the snippet fragment.
    // If there are none, we skip the <style> block entirely.
    let inlineCSS: String?
    if sheets.isEmpty {
        inlineCSS = nil
    } else {
        inlineCSS = CSSStyleSheet.renderedMerged(
            sheets,
            forNodeCollections: [fragment],
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
        fragment
    }

    return doc.render(
        default: .pretty,
        environment: env,
        onGate: onGate
    )
}
