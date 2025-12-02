import Foundation
import plate

public struct CSSStyleSheet: Sendable, Equatable {
    public var rules: [CSSRule]
    public var media: [CSSMedia]
    public var keyframes: [CSSKeyframes]

    public var rules_metasection: [CSSRuleMetaSection]? = nil
    public var media_metasection: [CSSMediaMetaSection]? = nil
    public var keyframes_metasection: [CSSKeyframesMetaSection]? = nil

    public init(
        rules: [CSSRule],
        media: [CSSMedia] = [],
        keyframes: [CSSKeyframes] = []
    ) {
        self.rules = rules
        self.media = media
        self.keyframes = keyframes
    }

    public init(
        rules: [CSSRuleMetaSection],
        media: [CSSMediaMetaSection] = [],
        keyframes: [CSSKeyframesMetaSection] = []
    ) {
        self.rules_metasection = rules
        self.media_metasection = media
        self.keyframes_metasection = keyframes

        self.rules = rules.flatMap(\.items)
        self.media = media.flatMap(\.items)
        self.keyframes = keyframes.flatMap(\.items)
    }

    /// Merge multiple stylesheets into a single sheet, preserving order.
    // public static func merged(_ sheets: [CSSStyleSheet]) -> CSSStyleSheet {
    //     var allRules: [CSSRule] = []
    //     var allMedia: [CSSMedia] = []
    //     var allKeyframes: [CSSKeyframes] = []

    //     allRules.reserveCapacity(sheets.reduce(0) { $0 + $1.rules.count })
    //     allMedia.reserveCapacity(sheets.reduce(0) { $0 + $1.media.count })
    //     allKeyframes.reserveCapacity(sheets.reduce(0) { $0 + $1.keyframes.count })

    //     for sheet in sheets {
    //         allRules.append(contentsOf: sheet.rules)
    //         allMedia.append(contentsOf: sheet.media)
    //         allKeyframes.append(contentsOf: sheet.keyframes)
    //     }

    //     return CSSStyleSheet(
    //         rules: allRules,
    //         media: allMedia,
    //         keyframes: allKeyframes
    //     )
    // }

    static func merged(_ sheets: [CSSStyleSheet]) -> CSSStyleSheet {
        var allRules: [CSSRule] = []
        var allMedia: [CSSMedia] = []
        var allKeyframes: [CSSKeyframes] = []

        allRules.reserveCapacity(sheets.reduce(0) { $0 + $1.rules.count })
        allMedia.reserveCapacity(sheets.reduce(0) { $0 + $1.media.count })
        allKeyframes.reserveCapacity(sheets.reduce(0) { $0 + $1.keyframes.count })

        var allRuleMeta: [CSSRuleMetaSection] = []
        var allMediaMeta: [CSSMediaMetaSection] = []
        var allKeyframesMeta: [CSSKeyframesMetaSection] = []

        var hasRuleMeta = true
        var hasMediaMeta = true
        var hasKeyframesMeta = true

        for sheet in sheets {
            allRules.append(contentsOf: sheet.rules)
            allMedia.append(contentsOf: sheet.media)
            allKeyframes.append(contentsOf: sheet.keyframes)

            if let meta = sheet.rules_metasection {
                allRuleMeta.append(contentsOf: meta)
            } else {
                hasRuleMeta = false
            }

            if let meta = sheet.media_metasection {
                allMediaMeta.append(contentsOf: meta)
            } else {
                hasMediaMeta = false
            }

            if let meta = sheet.keyframes_metasection {
                allKeyframesMeta.append(contentsOf: meta)
            } else {
                hasKeyframesMeta = false
            }
        }

        var merged = CSSStyleSheet(
            rules: allRules,
            media: allMedia,
            keyframes: allKeyframes
        )

        merged.rules_metasection =
            hasRuleMeta ? allRuleMeta : nil
        merged.media_metasection =
            hasMediaMeta ? allMediaMeta : nil
        merged.keyframes_metasection =
            hasKeyframesMeta ? allKeyframesMeta : nil

        return merged
    }

    /// Convenience: create a stylesheet by merging several others.
    public init(_ sheets: [CSSStyleSheet]) {
        self = CSSStyleSheet.merged(sheets)
    }

    /// Convenience: varargs merge.
    public init(_ sheets: CSSStyleSheet...) {
        self = CSSStyleSheet.merged(sheets)
    }

    /// Convenience: array overload
    public init(nested sheets: [[CSSStyleSheet]]) {
        let s = sheets.flatMap { $0 }
        self = CSSStyleSheet.merged(s)
    }

    public init(nested sheets: [CSSStyleSheet]...) {
        let s = sheets.flatMap { $0 }
        self = CSSStyleSheet.merged(s)
    }
}

// extension CSSStyleSheet {
//     public func render(indentation: Int = 4) -> String {
//         var out = ""

//         // top-level rules
//         for rule in rules {
//             out += renderRule(rule, indentation: indentation, times: 0)
//         }

//         // media blocks
//         for m in media {
//             out += renderMedia(m, indentation: indentation)
//         }

//         return out
//     }

//     /// Render a rule with an indent *level* (times).
//     private func renderRule(
//         _ rule: CSSRule,
//         indentation: Int,
//         times: Int
//     ) -> String {
//         var out = ""

//         // selector line
//         let selectorLine = "\(rule.selector) {"
//         if times > 0 {
//             out += selectorLine.indent(indentation, times: times)
//         } else {
//             out += selectorLine
//         }
//         out += "\n"

//         // declarations
//         let declTimes = times + 1
//         for decl in rule.declarations {
//             out += "\(decl.property): \(decl.value);".indent(indentation, times: declTimes)
//             out += "\n"
//         }

//         // closing brace
//         let closing = "}"
//         if times > 0 {
//             out += closing.indent(indentation, times: times)
//         } else {
//             out += closing
//         }
//         out += "\n\n"

//         return out
//     }

//     private func renderMedia(
//         _ media: CSSMedia,
//         indentation: Int
//     ) -> String {
//         var out = ""

//         // @media line (no indent, like top-level rules)
//         out += "@media \(media.query) {\n"

//         // Inner rules, one indent level inside the media block
//         for rule in media.rules {
//             out += renderRule(rule, indentation: indentation, times: 1)
//         }

//         out += "}\n\n"
//         return out
//     }
// }

extension CSSStyleSheet {
    public func render(options: CSSRenderOptions = CSSRenderOptions()) -> String {
        // now optionally merge duplicate selectors before rendering
        let sheet = options.mergeDuplicateSelectors
            ? self.mergingDuplicateSelectors()
            : self

        var out = ""

        func appendRule(_ rule: CSSRule, _ baseIndentTimes: Int) {
            let decision = decide(rule: rule, options: options)

            switch decision {
            case .keep:
                out += renderRule(rule, options: options, times: baseIndentTimes)

            case .commented:
                let rendered = renderRule(rule, options: options, times: baseIndentTimes)
                out += "/* UNUSED RULE START */\n"
                out += rendered
                out += "/* UNUSED RULE END */\n\n"

            case .drop:
                break
            }
        }

        // top-level rules
        for rule in sheet.rules {
            appendRule(rule, 0)
        }

        // keyframes (never pruned for now)
        for kf in sheet.keyframes {
            out += renderKeyframes(kf, options: options)
        }

        // media blocks
        for m in sheet.media {
            let renderedMedia = renderMedia(m, options: options)
            if !renderedMedia.isEmpty {
                out += renderedMedia
            }
        }

        if options.ensureTrailingNewline, !out.hasSuffix("\n") {
            out.append("\n")
        }

        return out
    }

    // public func render(options: CSSRenderOptions = CSSRenderOptions()) -> String {
    //     var out = ""

    //     func appendRule(_ rule: CSSRule, _ baseIndentTimes: Int) {
    //         let decision = decide(rule: rule, options: options)

    //         switch decision {
    //         case .keep:
    //             out += renderRule(rule, options: options, times: baseIndentTimes)

    //         case .commented:
    //             let rendered = renderRule(rule, options: options, times: baseIndentTimes)
    //             out += "/* UNUSED RULE START */\n"
    //             out += rendered
    //             out += "/* UNUSED RULE END */\n\n"

    //         case .drop:
    //             break
    //         }
    //     }

    //     // top-level rules
    //     for rule in rules {
    //         appendRule(rule, 0)
    //     }

    //     // keyframes (never pruned for now)
    //     for kf in keyframes {
    //         out += renderKeyframes(kf, options: options)
    //     }

    //     // media blocks
    //     for m in media {
    //         let renderedMedia = renderMedia(m, options: options)
    //         if !renderedMedia.isEmpty {
    //             out += renderedMedia
    //         }
    //     }

    //     if options.ensureTrailingNewline, !out.hasSuffix("\n") {
    //         out.append("\n")
    //     }

    //     return out
    // }

    /// Render a rule with an indent *level* (times).
    private func renderRule(
        _ rule: CSSRule,
        options: CSSRenderOptions,
        times: Int
    ) -> String {
        let indentation = options.indentStep
        var out = ""

        let selectorLine = "\(rule.selector) {"
        if times > 0 {
            out += selectorLine.indent(indentation, times: times)
        } else {
            out += selectorLine
        }
        out += "\n"

        let declTimes = times + 1
        for decl in rule.declarations {
            out += "\(decl.property): \(decl.value);".indent(indentation, times: declTimes)
            out += "\n"
        }

        let closing = "}"
        if times > 0 {
            out += closing.indent(indentation, times: times)
        } else {
            out += closing
        }
        out += "\n\n"

        return out
    }

    private func renderKeyframes(
        _ keyframes: CSSKeyframes,
        options: CSSRenderOptions
    ) -> String {
        let indentation = options.indentStep
        var out = ""

        // @keyframes line
        out += "@keyframes \(keyframes.name) {\n"

        for step in keyframes.steps {
            out += renderKeyframeStep(step, indentation: indentation, times: 1)
        }

        out += "}\n\n"
        return out
    }

    private func renderKeyframeStep(
        _ step: CSSKeyframeStep,
        indentation: Int,
        times: Int
    ) -> String {
        var out = ""

        // selector line, e.g. "from {" or "50% {"
        let selectorLine = "\(step.selector) {"
        if times > 0 {
            out += selectorLine.indent(indentation, times: times)
        } else {
            out += selectorLine
        }
        out += "\n"

        let declTimes = times + 1
        for decl in step.declarations {
            out += "\(decl.property): \(decl.value);".indent(indentation, times: declTimes)
            out += "\n"
        }

        let closing = "}"
        if times > 0 {
            out += closing.indent(indentation, times: times)
        } else {
            out += closing
        }
        out += "\n"

        return out
    }

    private func renderMedia(
        _ media: CSSMedia,
        options: CSSRenderOptions
    ) -> String {
        var inner = ""

        for rule in media.rules {
            let decision = decide(rule: rule, options: options)
            switch decision {
            case .keep:
                inner += renderRule(rule, options: options, times: 1)

            case .commented:
                let rendered = renderRule(rule, options: options, times: 1)
                inner += "/* UNUSED RULE START */\n"
                inner += rendered
                inner += "/* UNUSED RULE END */\n\n"

            case .drop:
                break
            }
        }

        guard !inner.isEmpty else { return "" }

        var out = ""
        out += "@media \(media.query) {\n"
        out += inner
        out += "}\n\n"
        return out
    }

// extension CSSStyleSheet {
//     // Back-compat: same signature as before, just delegates into options-based render.
//     // public func render(indentation: Int = 4) -> String {
//     //     let opts = CSSRenderOptions(indentStep: indentation)
//     //     return render(options: opts)
//     // }

//     /// New: render with richer options (indentation + unreferenced pruning).
//     public func render(options: CSSRenderOptions = CSSRenderOptions()) -> String {
//         var out = ""

//         // Helper to append a single rule at a given indent "times" level.
//         func appendRule(_ rule: CSSRule,_ baseIndentTimes: Int) {
//             let decision = decide(rule: rule, options: options)

//             switch decision {
//             case .keep:
//                 out += renderRule(rule, options: options, times: baseIndentTimes)

//             case .commented:
//                 let rendered = renderRule(rule, options: options, times: baseIndentTimes)
//                 out += "/* UNUSED RULE START */\n"
//                 out += rendered
//                 out += "/* UNUSED RULE END */\n\n"

//             case .drop:
//                 break
//             }
//         }

//         // top-level rules
//         for rule in rules {
//             appendRule(rule, 0)
//         }

//         // media blocks
//         for m in media {
//             let renderedMedia = renderMedia(m, options: options)
//             if !renderedMedia.isEmpty {
//                 out += renderedMedia
//             }
//         }

//         if options.ensureTrailingNewline, !out.hasSuffix("\n") {
//             out.append("\n")
//         }

//         return out
//     }

//     /// Render a rule with an indent *level* (times).
//     private func renderRule(
//         _ rule: CSSRule,
//         options: CSSRenderOptions,
//         times: Int
//     ) -> String {
//         let indentation = options.indentStep
//         var out = ""

//         // selector line
//         let selectorLine = "\(rule.selector) {"
//         if times > 0 {
//             out += selectorLine.indent(indentation, times: times)
//         } else {
//             out += selectorLine
//         }
//         out += "\n"

//         // declarations
//         let declTimes = times + 1
//         for decl in rule.declarations {
//             out += "\(decl.property): \(decl.value);".indent(indentation, times: declTimes)
//             out += "\n"
//         }

//         // closing brace
//         let closing = "}"
//         if times > 0 {
//             out += closing.indent(indentation, times: times)
//         } else {
//             out += closing
//         }
//         out += "\n\n"

//         return out
//     }

//     private func renderMedia(
//         _ media: CSSMedia,
//         options: CSSRenderOptions
//     ) -> String {
//         var inner = ""

//         for rule in media.rules {
//             let decision = decide(rule: rule, options: options)
//             switch decision {
//             case .keep:
//                 inner += renderRule(rule, options: options, times: 1)

//             case .commented:
//                 let rendered = renderRule(rule, options: options, times: 1)
//                 inner += "/* UNUSED RULE START */\n"
//                 inner += rendered
//                 inner += "/* UNUSED RULE END */\n\n"

//             case .drop:
//                 break
//             }
//         }

//         // If nothing survived inside this media block, omit it entirely
//         // when using a dropping policy.
//         guard !inner.isEmpty else { return "" }

//         var out = ""
//         out += "@media \(media.query) {\n"
//         out += inner
//         out += "}\n\n"
//         return out
//     }
    private enum RuleDecision {
        case keep
        case drop
        case commented
    }

    private enum SelectorUsage {
        case used
        case unused
        case unknown
    }

    private func decide(rule: CSSRule, options: CSSRenderOptions) -> RuleDecision {
        guard
            (options.usedClassNames?.isEmpty == false) ||
            (options.usedIDs?.isEmpty == false)
        else {
            return .keep
        }

        guard options.unreferenced != .keep else {
            return .keep
        }

        switch isSelectorUsed(
            rule.selector,
            usedClasses: options.usedClassNames ?? [],
            usedIDs: options.usedIDs ?? []
        ) {
        case .unknown, .used:
            return .keep

        case .unused:
            switch options.unreferenced {
            case .keep:
                return .keep
            case .drop:
                return .drop
            case .commented:
                return .commented
            }
        }
    }

    private func isSelectorUsed(
        _ selector: String,
        usedClasses: Set<String>,
        usedIDs: Set<String>
    ) -> SelectorUsage {
        let parts = selector.split(separator: ",")
        var anyUsed = false
        var anySimpleSeen = false
        var anyUnknown = false

        for rawPart in parts {
            let part = rawPart.trimmingCharacters(in: .whitespacesAndNewlines)

            let classes = extractClasses(from: part)
            let ids = extractIDs(from: part)

            // If this selector part has anything *besides* simple `.class` or `#id`
            // tokens, we treat it as unknown and bail out of pruning.
            if selectorHasNonClassIdSyntax(part) {
                anyUnknown = true
                continue
            }

            if classes.isEmpty && ids.isEmpty {
                anyUnknown = true
                continue
            }

            anySimpleSeen = true

            if !usedClasses.isDisjoint(with: classes) || !usedIDs.isDisjoint(with: ids) {
                anyUsed = true
            }
        }

        if anyUsed {
            return .used
        }

        if !anySimpleSeen || anyUnknown {
            return .unknown
        }

        // Every part was simple (.class / #id only) and all referenced tokens
        // were missing from the HTML.
        return .unused
    }

    private func extractClasses(from selector: String) -> Set<String> {
        var result = Set<String>()
        var current = ""
        var i = selector.startIndex

        while i < selector.endIndex {
            let ch = selector[i]

            if ch == "." {
                current.removeAll()
                i = selector.index(after: i)
                while i < selector.endIndex {
                    let c = selector[i]
                    if isClassOrIdCharacter(c) {
                        current.append(c)
                        i = selector.index(after: i)
                    } else {
                        break
                    }
                }
                if !current.isEmpty {
                    result.insert(current)
                }
                continue
            }

            i = selector.index(after: i)
        }

        return result
    }

    private func extractIDs(from selector: String) -> Set<String> {
        var result = Set<String>()
        var current = ""
        var i = selector.startIndex

        while i < selector.endIndex {
            let ch = selector[i]

            if ch == "#" {
                current.removeAll()
                i = selector.index(after: i)
                while i < selector.endIndex {
                    let c = selector[i]
                    if isClassOrIdCharacter(c) {
                        current.append(c)
                        i = selector.index(after: i)
                    } else {
                        break
                    }
                }
                if !current.isEmpty {
                    result.insert(current)
                }
                continue
            }

            i = selector.index(after: i)
        }

        return result
    }

    private func selectorHasNonClassIdSyntax(_ selector: String) -> Bool {
        // Very conservative: if we see characters that usually indicate
        // combinators, attribute selectors, pseudo-classes, etc., we bail.
        let forbidden: Set<Character> = [" ", ">", "+", "~", "[", "]", ":", "*"]

        for c in selector {
            if forbidden.contains(c) {
                return true
            }
        }

        return false
    }

    private func isClassOrIdCharacter(_ c: Character) -> Bool {
        c.isLetter || c.isNumber || c == "-" || c == "_"
    }
}

extension Array where Element == [CSSStyleSheet] {
    public func merged() -> CSSStyleSheet {
        let flat = self.flatMap { $0 }
        return CSSStyleSheet.merged(flat)
    }
}

extension Array where Element == CSSStyleSheet {
    /// Merge an array of stylesheets into a single one, preserving order.
    public func merged() -> CSSStyleSheet {
        CSSStyleSheet.merged(self)
    }

    // /// Render an array of stylesheets as if they were a single sheet.
    // public func render(indentation: Int = 4) -> String {
    //     merged().render(indentation: indentation)
    // }

    public func render(options: CSSRenderOptions) -> String {
        merged().render(options: options)
    }
}

extension CSSStyleSheet {
    /// Render this stylesheet, pruned against a single HTML fragment.
    public func rendered(
        forNodes nodes: HTMLFragment,
        indentStep: Int = 4,
        ensureTrailingNewline: Bool = true,
        unreferenced: CSSUnreferenced = .drop
    ) -> String {
        let options = CSSRenderOptions.forNodes(
            nodes,
            indentStep: indentStep,
            ensureTrailingNewline: ensureTrailingNewline,
            unreferenced: unreferenced
        )
        return render(options: options)
    }

    /// Render this stylesheet, pruned against multiple HTML fragments.
    /// Useful if you already have several node collections (pages, components, etc.).
    public func rendered(
        forNodeCollections collections: [HTMLFragment],
        indentStep: Int = 4,
        ensureTrailingNewline: Bool = true,
        unreferenced: CSSUnreferenced = .drop
    ) -> String {
        var usedClasses = Set<String>()
        var usedIDs = Set<String>()

        for nodes in collections {
            let doc = nodes.htmlDocument
            usedClasses.formUnion(doc.collectedClassNames())
            usedIDs.formUnion(doc.collectedIDs())
        }

        let options = CSSRenderOptions(
            indentStep: indentStep,
            ensureTrailingNewline: ensureTrailingNewline,
            usedClassNames: usedClasses,
            usedIDs: usedIDs,
            unreferenced: unreferenced
        )

        return render(options: options)
    }

    /// Convenience: merged sheets → single rendered bundle for given node collections.
    public static func renderedMerged(
        _ sheets: [CSSStyleSheet],
        forNodeCollections collections: [HTMLFragment],
        indentStep: Int = 4,
        ensureTrailingNewline: Bool = true,
        unreferenced: CSSUnreferenced = .drop
    ) -> String {
        CSSStyleSheet.merged(sheets).rendered(
            forNodeCollections: collections,
            indentStep: indentStep,
            ensureTrailingNewline: ensureTrailingNewline,
            unreferenced: unreferenced
        )
    }

    public func rendered(
        forDocuments documents: [HTMLDocument],
        indentStep: Int = 4,
        ensureTrailingNewline: Bool = true,
        unreferenced: CSSUnreferenced = .drop
    ) -> String {
        let options = CSSRenderOptions.forDocuments(
            documents,
            indentStep: indentStep,
            ensureTrailingNewline: ensureTrailingNewline,
            unreferenced: unreferenced
        )
        return render(options: options)
    }
}

extension CSSStyleSheet {
    /// Returns all custom properties (`--foo`) from rules matching `selector`.
    ///
    /// - Parameters:
    ///   - selector: CSS selector to match rules on (defaults to `:root`).
    ///   - filter:   Optional filter on the resulting tokens.
    public func customProperties(
        selector: String = ":root",
        filter: ((CSSCustomProperty) -> Bool)? = nil
    ) -> [CSSCustomProperty] {
        _extractCustomCSSProperties(from: rules, selector: selector, filter: filter)
    }

    public func renderedStyleProfile(
        title: String,
        subtitle: String? = nil,
        selector: String = ":root",
        includeUngroupedGroup: Bool = true,
        ungroupedTitle: String = "Other tokens"
    ) -> RenderedStyleProfile {
        RenderedStyleProfile.fromStyleSheet(
            self,
            title: title,
            subtitle: subtitle,
            selector: selector,
            includeUngroupedGroup: includeUngroupedGroup,
            ungroupedTitle: ungroupedTitle
        )
    }
}

extension CSSStyleSheet {
    /// Returns a new stylesheet where rules with identical selectors
    /// are merged into a single rule, preserving selector order and
    /// declaration order. Media blocks are merged similarly.
    public func mergingDuplicateSelectors() -> CSSStyleSheet {
        func mergeRules(_ rules: [CSSRule]) -> [CSSRule] {
            var out: [CSSRule] = []
            var indexBySelector: [String: Int] = [:]

            out.reserveCapacity(rules.count)

            for rule in rules {
                if let idx = indexBySelector[rule.selector] {
                    // Append declarations to the first occurrence
                    out[idx].declarations.append(contentsOf: rule.declarations)
                } else {
                    indexBySelector[rule.selector] = out.count
                    out.append(rule)
                }
            }

            return out
        }

        let mergedTopLevel = mergeRules(self.rules)

        let mergedMedia = self.media.map { mediaBlock in
            CSSMedia(
                query: mediaBlock.query,
                rules: mergeRules(mediaBlock.rules)
            )
        }

        return CSSStyleSheet(
            rules: mergedTopLevel,
            media: mergedMedia,
            keyframes: self.keyframes
        )
    }
}
