import CSS

public extension NavigationInterface {
    static func desktopMenuStyles() -> CSSStyleSheet {
        CSSStyleSheet(
            rules: [
                CSS.rule(
                    ".nested-navigation-menu--desktop",
                    CSS.decl("position", "relative"),
                    CSS.decl("display", "inline-block"),
                    // CSS.decl("margin-right", "12px"),
                    CSS.decl("font-size", "0.95rem")
                ),
                CSS.rule(
                    ".nested-navigation-menu__trigger",
                    CSS.decl("display", "inline-flex"),
                    CSS.decl("align-items", "center"),
                    CSS.decl("gap", "4px"),
                    CSS.decl("padding", "0.45rem 0.85rem"),
                    CSS.decl("border-radius", "999px"),
                    CSS.decl("border", "1px solid rgba(0,0,0,0.06)"),
                    CSS.decl("background", "#ffffff"),
                    CSS.decl("cursor", "pointer"),
                    CSS.decl("font", "inherit"),
                    CSS.decl("line-height", "1.1")
                ),
                CSS.rule(
                    ".nested-navigation-menu__trigger-icon",
                    CSS.decl("font-size", "0.7em"),
                    CSS.decl("transform-origin", "center"),
                    CSS.decl("transition", "transform 0.15s ease-out")
                ),
                CSS.rule(
                    ".nested-navigation-menu__panel",
                    CSS.decl("position", "absolute"),
                    CSS.decl("right", "0"),
                    CSS.decl("top", "calc(100% + 8px)"),
                    CSS.decl("min-width", "260px"),
                    CSS.decl("max-width", "360px"),
                    CSS.decl("max-height", "min(60vh, 480px)"),
                    CSS.decl("overflow", "auto"),
                    CSS.decl("padding", "8px 0"),
                    CSS.decl("border-radius", "12px"),
                    CSS.decl("background", "#ffffff"),
                    // CSS.decl("box-shadow", "0 18px 40px rgba(15,23,42,0.16), 0 0 0 1px rgba(15,23,42,0.04)"),
                    CSS.decl("opacity", "0"),
                    CSS.decl("pointer-events", "none"),
                    CSS.decl("transform", "translateY(-4px)"),
                    CSS.decl("transition", "opacity 0.15s ease-out, transform 0.15s ease-out"),
                    CSS.decl("z-index", "80")
                ),
                CSS.rule(
                    ".nested-navigation-menu__panel.is-open",
                    CSS.decl("opacity", "1"),
                    CSS.decl("pointer-events", "auto"),
                    CSS.decl("transform", "translateY(0)")
                ),
                CSS.rule(
                    ".nested-navigation-menu__list",
                    CSS.decl("list-style", "none"),
                    CSS.decl("margin", "0"),
                    CSS.decl("padding", "0")
                ),
                CSS.rule(
                    ".nested-navigation-menu__item",
                    CSS.decl("padding-inline", "8px")
                ),
                CSS.rule(
                    ".nested-navigation-menu__row",
                    CSS.decl("display", "flex"),
                    CSS.decl("align-items", "center"),
                    CSS.decl("justify-content", "space-between"),
                    CSS.decl("gap", "4px"),
                    CSS.decl("padding", "4px 8px"),
                    CSS.decl("border-radius", "8px")
                ),
                CSS.rule(
                    ".nested-navigation-menu__link, .nested-navigation-menu__label",
                    CSS.decl("display", "inline-flex"),
                    CSS.decl("align-items", "center"),
                    CSS.decl("font-size", "0.92rem"),
                    CSS.decl("line-height", "1.3"),
                    CSS.decl("text-decoration", "none"),
                    CSS.decl("color", "#111827")
                ),
                CSS.rule(
                    ".nested-navigation-menu__link:hover",
                    CSS.decl("text-decoration", "underline")
                ),
                CSS.rule(
                    ".nested-navigation-menu__item--level-1 .nested-navigation-menu__row",
                    CSS.decl("padding-left", "16px")
                ),
                CSS.rule(
                    ".nested-navigation-menu__item--level-2 .nested-navigation-menu__row",
                    CSS.decl("padding-left", "24px")
                ),
                CSS.rule(
                    ".nested-navigation-menu__item--level-3 .nested-navigation-menu__row",
                    CSS.decl("padding-left", "32px")
                ),

                CSS.rule(
                    """
                    .nested-navigation-menu__item--level-1 .nested-navigation-menu__link::before,
                    .nested-navigation-menu__item--level-1 .nested-navigation-menu__label::before,
                    .nested-navigation-menu__item--level-2 .nested-navigation-menu__link::before,
                    .nested-navigation-menu__item--level-2 .nested-navigation-menu__label::before,
                    .nested-navigation-menu__item--level-3 .nested-navigation-menu__link::before,
                    .nested-navigation-menu__item--level-3 .nested-navigation-menu__label::before
                    """,
                    CSS.decl("content", "\"└─ \""),
                    CSS.decl("margin-right", "4px"),
                    CSS.decl("opacity", "0.7"),
                    CSS.decl("font-size", "0.9em")
                ),

                // CSS.rule(
                //     ".nested-navigation-menu__toggle",
                //     CSS.decl("border", "none"),
                //     CSS.decl("background", "none"),
                //     CSS.decl("padding", "2px 0 2px 4px"),
                //     CSS.decl("cursor", "pointer"),
                //     CSS.decl("display", "inline-flex"),
                //     CSS.decl("align-items", "center")
                // ),
                // CSS.rule(
                //     ".nested-navigation-menu__toggle-icon",
                //     CSS.decl("font-size", "0.7rem"),
                //     CSS.decl("transition", "transform 0.15s ease-out")
                // ),

                CSS.rule(
                    ".nested-navigation-menu__toggle",
                    CSS.decl("border", "1px solid rgba(0,0,0,0.12)"),
                    CSS.decl("background", "#f5f5f5"),
                    CSS.decl("padding", "0"),
                    CSS.decl("cursor", "pointer"),
                    CSS.decl("display", "inline-flex"),
                    CSS.decl("align-items", "center"),
                    CSS.decl("justify-content", "center"),
                    CSS.decl("width", "24px"),
                    CSS.decl("height", "24px"),
                    CSS.decl("border-radius", "999px"),
                    CSS.decl("flex-shrink", "0"),
                    CSS.decl("margin-left", "6px")
                ),

                CSS.rule(
                    ".nested-navigation-menu__toggle-icon",
                    CSS.decl("font-size", "0.85rem"),
                    CSS.decl("line-height", "1"),
                    CSS.decl("transform-origin", "center"),
                    CSS.decl("transition", "transform 0.15s ease-out")
                ),

                CSS.rule(
                    ".nested-navigation-menu__toggle[aria-expanded=\"true\"] .nested-navigation-menu__toggle-icon",
                    CSS.decl("transform", "rotate(90deg)")
                ),

                CSS.rule(
                    ".nested-navigation-menu__children",
                    CSS.decl("display", "none"),
                    CSS.decl("padding-top", "2px"),
                    CSS.decl("padding-bottom", "2px")
                ),
                CSS.rule(
                    ".nested-navigation-menu__children.is-open",
                    CSS.decl("display", "block")
                ),
            ],

            media: [
                CSS.media(
                    "(max-width: 640px)",
                    CSS.rule(
                        ".nested-navigation-menu--desktop",
                        CSS.decl("display", "none")
                    )
                )
            ]
        )
    }
}

public extension NavigationInterface {
    static func mobileMenuStyles() -> CSSStyleSheet {
        CSSStyleSheet(
            rules: [
                CSS.rule(
                    ".nested-navigation-menu-mobile__list",
                    CSS.decl("list-style", "none"),
                    CSS.decl("margin", "0"),
                    CSS.decl("padding", "0")
                ),
                CSS.rule(
                    ".nested-navigation-menu-mobile__item",
                    CSS.decl("margin", "0"),
                    CSS.decl("padding", "0")
                ),

                CSS.rule(
                    ".nested-navigation-menu-mobile__row",
                    CSS.decl("display", "flex"),
                    CSS.decl("align-items", "center"),
                    // CSS.decl("justify-content", "space-between"),
                    CSS.decl("justify-content", "flex-start"),
                    CSS.decl("gap", "4px")
                ),

                CSS.rule(
                    ".nested-navigation-menu-mobile__link, .nested-navigation-menu-mobile__label",
                    CSS.decl("display", "block"),
                    CSS.decl("padding", "8px 0"),
                    CSS.decl("text-decoration", "none"),
                    CSS.decl("color", "inherit"),
                    CSS.decl("font-size", "1rem"),
                    CSS.decl("text-align", "left")  
                ),

                // children hidden by default
                CSS.rule(
                    ".nested-navigation-menu-mobile__children",
                    CSS.decl("display", "none"),
                    CSS.decl("margin-top", "4px")
                ),
                CSS.rule(
                    ".nested-navigation-menu-mobile__children.is-open",
                    CSS.decl("display", "block")
                ),

                // CSS.rule(
                //     ".nested-navigation-menu-mobile__toggle",
                //     CSS.decl("border", "none"),
                //     CSS.decl("background", "none"),
                //     CSS.decl("padding", "4px 0 4px 8px"),
                //     CSS.decl("cursor", "pointer"),
                //     CSS.decl("display", "inline-flex"),
                //     CSS.decl("align-items", "center")
                // ),
                // CSS.rule(
                //     ".nested-navigation-menu-mobile__toggle-icon",
                //     CSS.decl("font-size", "0.8rem"),
                //     CSS.decl("transition", "transform 0.15s ease-out")
                // ),

                CSS.rule(
                    ".nested-navigation-menu-mobile__toggle",
                    CSS.decl("border", "1px solid rgba(0,0,0,0.15)"),
                    CSS.decl("background", "#f5f5f5"),
                    CSS.decl("padding", "0"),
                    CSS.decl("cursor", "pointer"),
                    CSS.decl("display", "inline-flex"),
                    CSS.decl("align-items", "center"),
                    CSS.decl("justify-content", "center"),

                    // make it a proper thumb target
                    CSS.decl("width", "32px"),
                    CSS.decl("height", "32px"),
                    CSS.decl("border-radius", "999px"),

                    // keep layout sane
                    CSS.decl("flex-shrink", "0"),
                    CSS.decl("margin-left", "8px")
                ),

                CSS.rule(
                    ".nested-navigation-menu-mobile__toggle-icon",
                    CSS.decl("font-size", "1rem"),                  // bigger symbol
                    CSS.decl("line-height", "1"),
                    CSS.decl("transform-origin", "center"),
                    CSS.decl("transition", "transform 0.15s ease-out")
                ),

                CSS.rule(
                    ".nested-navigation-menu-mobile__toggle[aria-expanded=\"true\"] .nested-navigation-menu-mobile__toggle-icon",
                    CSS.decl("transform", "rotate(90deg)")
                ),

                // border between siblings (using the li structure)
                CSS.rule(
                    ".nested-navigation-menu-mobile__item + .nested-navigation-menu-mobile__item .mobile-nav-items",
                    CSS.decl("border-top", "1px solid rgba(0,0,0,0.10)"),
                    CSS.decl("padding-top", "6px")
                ),

                // indentation per level (reuses .mobile-nav-items styling)
                CSS.rule(
                    ".nested-navigation-menu-mobile__item--level-0 .mobile-nav-items",
                    CSS.decl("padding-left", "0")
                ),
                CSS.rule(
                    ".nested-navigation-menu-mobile__item--level-1 .mobile-nav-items",
                    CSS.decl("padding-left", "16px")
                ),
                CSS.rule(
                    ".nested-navigation-menu-mobile__item--level-2 .mobile-nav-items",
                    CSS.decl("padding-left", "24px")
                ),
                CSS.rule(
                    ".nested-navigation-menu-mobile__item--level-3 .mobile-nav-items",
                    CSS.decl("padding-left", "32px")
                ),

                CSS.rule(
                    """
                    .nested-navigation-menu-mobile__item--level-1 .mobile-nav-items::before,
                    .nested-navigation-menu-mobile__item--level-2 .mobile-nav-items::before,
                    .nested-navigation-menu-mobile__item--level-3 .mobile-nav-items::before
                    """,
                    CSS.decl("content", "\"└─ \""),
                    CSS.decl("margin-right", "4px"),
                    CSS.decl("opacity", "0.7"),
                    CSS.decl("font-size", "0.95em")
                ),
            ],
            media: [
                CSS.media(
                    "(min-width: 641px)",
                    CSS.rule(
                        ".nested-navigation-menu-mobile",
                        CSS.decl("display", "none")
                    )
                )
            ]
        )
    }
}
