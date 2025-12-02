import Foundation

public extension RenderedStyleProfile {
    struct CSSDefaults: Sendable, Equatable {
        public var bodySelector: String
        public var rootClass: String
        public var titleClass: String
        public var subtitleClass: String
        public var gridClass: String
        public var groupClass: String
        public var groupTitleClass: String
        public var groupGridClass: String
        public var swatchClass: String
        public var chipClass: String
        public var metaClass: String
        public var varClass: String
        public var valueClass: String

        public init(
            bodySelector: String = "body",
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
        ) {
            self.bodySelector = bodySelector
            self.rootClass = rootClass
            self.titleClass = titleClass
            self.subtitleClass = subtitleClass
            self.gridClass = gridClass
            self.groupClass = groupClass
            self.groupTitleClass = groupTitleClass
            self.groupGridClass = groupGridClass
            self.swatchClass = swatchClass
            self.chipClass = chipClass
            self.metaClass = metaClass
            self.varClass = varClass
            self.valueClass = valueClass
        }
    }

    /// Default stylesheet for `RenderedStyleProfile.asHTMLSection(...)`.
    ///
    /// Uses CSS variables like `--bg`, `--text`, `--text-muted`, etc,
    /// but also provides sensible fallbacks so it still renders if those
    /// vars are missing.
    static func defaultCSS(
        _ defaults: CSSDefaults = CSSDefaults()
    ) -> CSSStyleSheet {
        CSSStyleSheet(
            rules: [
                CSS.rule(
                    defaults.bodySelector,
                    CSS.decl(
                        "font-family",
                        #""SF Pro Text", -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif"#
                    ),
                    // fallbacks ensure this works outside Hondenmeesters too
                    CSS.decl("background", "var(--bg, #0f172a)"),
                    CSS.decl("color", "var(--text, #0f1720)"),
                    CSS.decl("padding", "24px"),
                    CSS.decl("margin", "0")
                ),

                CSS.rule(
                    ".\(defaults.rootClass)",
                    CSS.decl("max-width", "1128px"),
                    CSS.decl("margin", "0 auto"),
                    CSS.decl("display", "flex"),
                    CSS.decl("flex-direction", "column"),
                    CSS.decl("gap", "24px")
                ),

                CSS.rule(
                    ".\(defaults.titleClass)",
                    CSS.decl("margin", "0 0 4px"),
                    CSS.decl("font-size", "1.5rem")
                ),

                CSS.rule(
                    ".\(defaults.subtitleClass)",
                    CSS.decl("margin", "0 0 12px"),
                    CSS.decl("color", "var(--text-muted, #6b7280)")
                ),

                CSS.rule(
                    ".\(defaults.gridClass)",
                    CSS.decl("display", "flex"),
                    CSS.decl("flex-direction", "column"),
                    CSS.decl("gap", "24px")
                ),

                CSS.rule(
                    ".\(defaults.groupClass)",
                    CSS.decl("border-radius", "12px"),
                    CSS.decl("padding", "16px 18px"),
                    CSS.decl("background", "var(--card-surface, #ffffff)"),
                    CSS.decl("border", "1px solid var(--card-border, #e5e7eb)")
                ),

                CSS.rule(
                    ".\(defaults.groupTitleClass)",
                    CSS.decl("margin", "0 0 12px"),
                    CSS.decl("font-size", "1rem"),
                    CSS.decl("text-transform", "uppercase"),
                    CSS.decl("letter-spacing", ".08em"),
                    CSS.decl("font-weight", "600"),
                    CSS.decl("color", "var(--caption-ink, #6b7280)")
                ),

                CSS.rule(
                    ".\(defaults.groupGridClass)",
                    CSS.decl("display", "grid"),
                    CSS.decl("grid-template-columns", "repeat(auto-fill, minmax(180px, 1fr))"),
                    CSS.decl("gap", "12px")
                ),

                CSS.rule(
                    ".\(defaults.swatchClass)",
                    CSS.decl("display", "flex"),
                    CSS.decl("align-items", "stretch"),
                    CSS.decl("gap", "10px"),
                    CSS.decl("padding", "8px"),
                    CSS.decl("border-radius", "10px"),
                    CSS.decl("background", "var(--surface-strong, #ffffff)"),
                    CSS.decl("border", "1px solid var(--border-subtle, #e5e7eb)")
                ),

                CSS.rule(
                    ".\(defaults.chipClass)",
                    CSS.decl("width", "40px"),
                    CSS.decl("border-radius", "8px"),
                    CSS.decl("border", "1px solid rgba(15,23,42,0.12)")
                ),

                CSS.rule(
                    ".\(defaults.metaClass)",
                    CSS.decl("display", "flex"),
                    CSS.decl("flex-direction", "column"),
                    CSS.decl("gap", "2px"),
                    CSS.decl("min-width", "0")
                ),

                CSS.rule(
                    ".\(defaults.varClass)",
                    CSS.decl("font-size", ".78rem"),
                    CSS.decl(
                        "font-family",
                        #""SF Mono", ui-monospace, Menlo, Monaco, Consolas, "Liberation Mono", "Courier New", monospace"#
                    ),
                    CSS.decl("color", "var(--caption-ink, #6b7280)")
                ),

                CSS.rule(
                    ".\(defaults.valueClass)",
                    CSS.decl("font-size", ".85rem"),
                    CSS.decl("color", "var(--text, #0f1720)")
                )
            ],
            media: [
                CSS.media(
                    "(max-width: 640px)",
                    CSS.rule(
                        defaults.bodySelector,
                        CSS.decl("padding", "16px")
                    )
                )
            ]
        )
    }
}
