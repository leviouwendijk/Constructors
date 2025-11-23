import Foundation
import plate

public struct CSSStyleSheet: Sendable, Equatable {
    public var rules: [CSSRule]
    public var media: [CSSMedia]
    public var keyframes: [CSSKeyframes]

    public init(
        rules: [CSSRule],
        media: [CSSMedia] = [],
        keyframes: [CSSKeyframes] = []
    ) {
        self.rules = rules
        self.media = media
        self.keyframes = keyframes
    }


    /// Merge multiple stylesheets into a single sheet, preserving order.
    public static func merged(_ sheets: [CSSStyleSheet]) -> CSSStyleSheet {
        var allRules: [CSSRule] = []
        var allMedia: [CSSMedia] = []
        var allKeyframes: [CSSKeyframes] = []

        allRules.reserveCapacity(sheets.reduce(0) { $0 + $1.rules.count })
        allMedia.reserveCapacity(sheets.reduce(0) { $0 + $1.media.count })
        allKeyframes.reserveCapacity(sheets.reduce(0) { $0 + $1.keyframes.count })

        for sheet in sheets {
            allRules.append(contentsOf: sheet.rules)
            allMedia.append(contentsOf: sheet.media)
            allKeyframes.append(contentsOf: sheet.keyframes)
        }

        return CSSStyleSheet(
            rules: allRules,
            media: allMedia,
            keyframes: allKeyframes
        )
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
        for rule in rules {
            appendRule(rule, 0)
        }

        // keyframes (never pruned for now)
        for kf in keyframes {
            out += renderKeyframes(kf, options: options)
        }

        // media blocks
        for m in media {
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
