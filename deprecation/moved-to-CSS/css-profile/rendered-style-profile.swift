import Foundation

/// High-level representation of a palette / set of CSS tokens you want to inspect visually.
public struct RenderedStyleProfile: Sendable, Equatable {
    public struct Swatch: Sendable, Equatable {
        /// CSS custom property name, e.g. `"--bg"`.
        public var name: String
        /// Human / raw label for the value, e.g. `"#ffffff"` or `"var(--gray-500)"`.
        public var value: String

        public init(name: String, value: String) {
            self.name = name
            self.value = value
        }
    }

    public struct Group: Sendable, Equatable {
        public var title: String
        public var swatches: [Swatch]

        public init(
            title: String,
            swatches: [Swatch]
        ) {
            self.title = title
            self.swatches = swatches
        }
    }

    public var title: String
    public var subtitle: String?
    public var groups: [Group]

    public init(
        title: String,
        subtitle: String? = nil,
        groups: [Group]
    ) {
        self.title = title
        self.subtitle = subtitle
        self.groups = groups
    }
}

// public extension RenderedStyleProfile {
//     /// Render this profile as a palette section using the default class names.
//     ///
//     /// `class` parameters let other projects override the classes
//     /// while keeping the same structure.
//     func asHTMLSection(
//         rootClass: String = "design-root-palette",
//         titleClass: String = "design-root-palette-title",
//         subtitleClass: String = "design-root-palette-subtitle",
//         gridClass: String = "design-root-palette-grid",
//         groupClass: String = "design-palette-group",
//         groupTitleClass: String = "design-palette-group-title",
//         groupGridClass: String = "design-palette-group-grid",
//         swatchClass: String = "design-swatch",
//         chipClass: String = "design-swatch-chip",
//         metaClass: String = "design-swatch-meta",
//         varClass: String = "design-swatch-var",
//         valueClass: String = "design-swatch-hex"
//     ) -> any HTMLNode {
//         HTML.section(["class": rootClass]) {
//             HTML.h1(["class": titleClass]) {
//                 HTML.text(title)
//             }

//             if let subtitle, !subtitle.isEmpty {
//                 HTML.p(["class": subtitleClass]) {
//                     HTML.text(subtitle)
//                 }
//             }

//             HTML.div(["class": gridClass]) {
//                 for group in groups {
//                     HTML.div(["class": groupClass]) {
//                         HTML.h2(["class": groupTitleClass]) {
//                             HTML.text(group.title)
//                         }

//                         HTML.div(["class": groupGridClass]) {
//                             for sw in group.swatches {
//                                 HTML.div(["class": swatchClass]) {
//                                     HTML.div(
//                                         [
//                                             "class": chipClass,
//                                             "style": "background: var(\(sw.name));"
//                                         ]
//                                     ) {}

//                                     HTML.div(["class": metaClass]) {
//                                         HTML.code(["class": varClass]) {
//                                             HTML.text(sw.name)
//                                         }
//                                         HTML.span(["class": valueClass]) {
//                                             HTML.text(sw.value)
//                                         }
//                                     }
//                                 }
//                             }
//                         }
//                     }
//                 }
//             }
//         }
//     }
// }

public extension RenderedStyleProfile {
    /// Build a swatch profile from a stylesheet.
    ///
    /// If the stylesheet was created from meta sections, those drive the grouping.
    /// Otherwise, all tokens end up in a single group.
    static func fromStyleSheet(
        _ sheet: CSSStyleSheet,
        title: String,
        subtitle: String? = nil,
        selector: String = ":root",
        includeUngroupedGroup: Bool = true,
        ungroupedTitle: String = "Other tokens"
    ) -> RenderedStyleProfile {
        if let sections = sheet.rules_metasection {
            return fromRuleMetaSections(
                sheet,
                ruleSections: sections,
                title: title,
                subtitle: subtitle,
                selector: selector,
                includeUngroupedGroup: includeUngroupedGroup,
                ungroupedTitle: ungroupedTitle
            )
        } else {
            // No meta info – just dump everything into one group.
            let tokens = sheet.customProperties(selector: selector)

            let group = Group(
                title: "All tokens",
                swatches: tokens
                    .sorted { $0.name < $1.name }
                    .map { Swatch(name: $0.name, value: $0.value) }
            )

            return RenderedStyleProfile(
                title: title,
                subtitle: subtitle,
                groups: [group]
            )
        }
    }

    /// Internal helper: meta-section driven grouping with optional leftovers.
    private static func fromRuleMetaSections(
        _ sheet: CSSStyleSheet,
        ruleSections: [CSSRuleMetaSection],
        title: String,
        subtitle: String?,
        selector: String,
        includeUngroupedGroup: Bool,
        ungroupedTitle: String
    ) -> RenderedStyleProfile {
        var groups: [Group] = []
        var usedNames = Set<String>()

        for section in ruleSections {
            let tokens = section.customProperties(selector: selector)
            guard !tokens.isEmpty else { continue }

            let swatches = tokens
                .sorted { $0.name < $1.name }
                .map {
                    usedNames.insert($0.name)
                    return Swatch(name: $0.name, value: $0.value)
                }

            groups.append(
                Group(
                    title: section.title,
                    swatches: swatches
                )
            )
        }

        if includeUngroupedGroup {
            let allTokens = sheet.customProperties(selector: selector)
            let leftovers = allTokens
                .filter { !usedNames.contains($0.name) }
                .sorted { $0.name < $1.name }
                .map { Swatch(name: $0.name, value: $0.value) }

            if !leftovers.isEmpty {
                groups.append(
                    Group(
                        title: ungroupedTitle,
                        swatches: leftovers
                    )
                )
            }
        }

        return RenderedStyleProfile(
            title: title,
            subtitle: subtitle,
            groups: groups
        )
    }
}
