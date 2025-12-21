import HTML

public extension NavigationInterface {
    func desktopMenuHTML() -> any HTMLNode {
        guard !roots.isEmpty else {
            return HTML.blank()
        }

        return HTML.nav(
            [
                "class": "nested-navigation-menu nested-navigation-menu--desktop",
                "aria-label": "Site navigatie"
            ]
        ) {
            HTML.button(
                [
                    "type": "button",
                    "class": "nested-navigation-menu__trigger",
                    "data-nested-navigation-menu": "trigger",
                    "aria-haspopup": "true",
                    "aria-expanded": "false",
                    "aria-controls": "nested-navigation-menu-panel"
                ]
            ) {
                HTML.span(["class": "nested-navigation-menu__trigger-label"]) {
                    HTML.text("Meer")
                }
                HTML.span(["class": "nested-navigation-menu__trigger-icon"]) {
                    HTML.text("▾")
                }
            }

            HTML.div(
                [
                    "id": "nested-navigation-menu-panel",
                    "class": "nested-navigation-menu__panel",
                    "data-nested-navigation-menu": "panel"
                ]
            ) {
                desktopRenderNodes(roots, level: 0)
            }
        }
    }

    private func desktopRenderNodes(
        _ nodes: [Node],
        level: Int
    ) -> any HTMLNode {
        HTML.el(
            "ul",
            [
                "class": "nested-navigation-menu__list nested-navigation-menu__list--level-\(level)"
            ]
        ) {
            for node in nodes {
                desktopRenderNode(node, level: level)
            }
        }
    }

    private func desktopRenderNode(
        _ node: Node,
        level: Int
    ) -> any HTMLNode {
        let baseClass = "nested-navigation-menu__item nested-navigation-menu__item--level-\(level)"
        let classValue = node.hasChildren
            ? baseClass + " nested-navigation-menu__item--has-children"
            : baseClass

        return HTML.el(
            "li",
            ["class": classValue]
        ) {
            HTML.div(["class": "nested-navigation-menu__row"]) {
                if let path = node.path {
                    HTML.a(
                        path,
                        [
                            "class": "nested-navigation-menu__link",
                            "data-nested-navigation-menu": "link"
                        ]
                    ) {
                        HTML.text(node.label)
                    }
                } else {
                    HTML.span(["class": "nested-navigation-menu__label"]) {
                        HTML.text(node.label)
                    }
                }

                if node.hasChildren {
                    HTML.button(
                        [
                            "type": "button",
                            "class": "nested-navigation-menu__toggle",
                            "data-nested-navigation-menu": "toggle",
                            "aria-expanded": "false"
                        ]
                    ) {
                        HTML.span(["class": "nested-navigation-menu__toggle-icon"]) {
                            HTML.text("▸")
                        }
                    }
                }
            }

            if node.hasChildren {
                HTML.div(
                    [
                        "class": "nested-navigation-menu__children",
                        "data-nested-navigation-menu": "group"
                    ]
                ) {
                    desktopRenderNodes(node.children, level: level + 1)
                }
            }
        }
    }
}

public extension NavigationInterface {
    func mobileMenuHTML() -> any HTMLNode {
        guard !roots.isEmpty else { return HTML.blank() }

        return mobileRenderNodes(roots, level: 0)
    }

    private func mobileRenderNodes(
        _ nodes: [Node],
        level: Int
    ) -> any HTMLNode {
        HTML.el(
            "ul",
            [
                "class": "nested-navigation-menu-mobile nested-navigation-menu-mobile__list nested-navigation-menu-mobile__list--level-\(level)"
            ]
        ) {
            for node in nodes {
                mobileRenderNode(node, level: level)
            }
        }
    }

    private func mobileRenderNode(
        _ node: Node,
        level: Int
    ) -> any HTMLNode {
        let baseClass = "nested-navigation-menu-mobile__item nested-navigation-menu-mobile__item--level-\(level)"

        return HTML.el(
            "li",
            ["class": baseClass]
        ) {
            // row with label/link + optional toggle
            HTML.div(["class": "nested-navigation-menu-mobile__row"]) {
                if let path = node.path {
                    // keep .mobile-nav-items so old JS continues to close overlay
                    HTML.a(
                        path,
                        ["class": "mobile-nav-items nested-navigation-menu-mobile__link"]
                    ) {
                        HTML.text(node.label)
                    }
                } else {
                    HTML.span(
                        ["class": "mobile-nav-items nested-navigation-menu-mobile__label"]
                    ) {
                        HTML.text(node.label)
                    }
                }

                if node.hasChildren {
                    HTML.button(
                        [
                            "type": "button",
                            "class": "nested-navigation-menu-mobile__toggle",
                            "data-nested-navigation-menu-mobile": "toggle",
                            "aria-expanded": "false"
                        ]
                    ) {
                        HTML.span(["class": "nested-navigation-menu-mobile__toggle-icon"]) {
                            HTML.text("▸")
                        }
                    }
                }
            }

            if node.hasChildren {
                HTML.div(
                    [
                        "class": "nested-navigation-menu-mobile__children",
                        "data-nested-navigation-menu-mobile": "group"
                    ]
                ) {
                    mobileRenderNodes(node.children, level: level + 1)
                }
            }
        }
    }
}
