import CSS
import HTML

public extension RenderedStyleProfile {
    /// Render this profile as a palette section using the default class names.
    ///
    /// `class` parameters let other projects override the classes
    /// while keeping the same structure.
    func asHTMLSection(
        rootClass: String = "design-root-palette",
        titleClass: String = "design-root-palette-title",
        subtitleClass: String = "design-root-palette-subtitle",
        gridClass: String = "design-root-palette-grid",
        groupClass: String = "design-palette-group",
        groupTitleClass: String = "design-palette-group-title",
        groupGridClass: String = "design-palette-group-grid",
        swatchClass: String = "design-swatch",
        chipClass: String = "design-swatch-chip",
        metaClass: String = "design-swatch-meta",
        varClass: String = "design-swatch-var",
        valueClass: String = "design-swatch-hex"
    ) -> any HTMLNode {
        HTML.section(["class": rootClass]) {
            HTML.h1(["class": titleClass]) {
                HTML.text(title)
            }

            if let subtitle, !subtitle.isEmpty {
                HTML.p(["class": subtitleClass]) {
                    HTML.text(subtitle)
                }
            }

            HTML.div(["class": gridClass]) {
                for group in groups {
                    HTML.div(["class": groupClass]) {
                        HTML.h2(["class": groupTitleClass]) {
                            HTML.text(group.title)
                        }

                        HTML.div(["class": groupGridClass]) {
                            for sw in group.swatches {
                                HTML.div(["class": swatchClass]) {
                                    HTML.div(
                                        [
                                            "class": chipClass,
                                            "style": "background: var(\(sw.name));"
                                        ]
                                    ) {}

                                    HTML.div(["class": metaClass]) {
                                        HTML.code(["class": varClass]) {
                                            HTML.text(sw.name)
                                        }
                                        HTML.span(["class": valueClass]) {
                                            HTML.text(sw.value)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
