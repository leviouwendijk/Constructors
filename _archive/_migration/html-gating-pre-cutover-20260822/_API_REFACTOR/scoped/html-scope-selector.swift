import HTML
import DSL

public enum HTMLScopeSelector {
    public static func select(
        _ selection: ScopeSelection,
        from nodes: HTMLFragment
    ) -> HTMLFragment {
        switch selection {
        case .all:
            return stripScopeWrappers(from: nodes)

        case .scoped(let scope):
            return extractScoped(
                matching: scope,
                from: nodes
            )

        case .unscoped:
            return prune(
                excluding: nil,
                from: nodes
            )

        case .excluding(let excluded):
            return prune(
                excluding: excluded,
                from: nodes
            )
        }
    }
}

private extension HTMLScopeSelector {
    static func stripScopeWrappers(
        from nodes: HTMLFragment
    ) -> HTMLFragment {
        var out: HTMLFragment = []

        for node in nodes {
            out.append(contentsOf: strip(node))
        }

        return out
    }

    static func strip(
        _ node: any HTMLNode
    ) -> HTMLFragment {
        switch node {
        case let region as HTMLBundledRegion:
            return stripScopeWrappers(
                from: region.children
            )

        case let element as HTMLElement:
            return [
                HTMLElement(
                    element.tag,
                    attrs: element.attrs,
                    children: stripScopeWrappers(
                        from: element.children
                    ),
                    selfClosing: element.selfClosing
                )
            ]

        case let inline as HTMLInlineGroup:
            return [
                HTMLInlineGroup(
                    stripScopeWrappers(
                        from: inline.children
                    )
                )
            ]

        case let gate as HTMLGate:
            return [
                HTMLGate(
                    id: gate.id,
                    allow: gate.allowed,
                    children: stripScopeWrappers(
                        from: gate.children
                    )
                )
            ]

        default:
            return [node]
        }
    }

    static func extractScoped(
        matching scope: ScopeIdentifier,
        from nodes: HTMLFragment
    ) -> HTMLFragment {
        var out: HTMLFragment = []

        for node in nodes {
            out.append(contentsOf: extract(
                node,
                matching: scope
            ))
        }

        return out
    }

    static func extract(
        _ node: any HTMLNode,
        matching scope: ScopeIdentifier
    ) -> HTMLFragment {
        switch node {
        case let region as HTMLBundledRegion:
            if region.scope == scope {
                return stripScopeWrappers(
                    from: region.children
                )
            }

            return extractScoped(
                matching: scope,
                from: region.children
            )

        case let element as HTMLElement:
            return extractScoped(
                matching: scope,
                from: element.children
            )

        case let inline as HTMLInlineGroup:
            return extractScoped(
                matching: scope,
                from: inline.children
            )

        case let gate as HTMLGate:
            return extractScoped(
                matching: scope,
                from: gate.children
            )

        default:
            return []
        }
    }

    static func prune(
        excluding excluded: Set<ScopeIdentifier>?,
        from nodes: HTMLFragment
    ) -> HTMLFragment {
        var out: HTMLFragment = []

        for node in nodes {
            if let selected = prune(node, excluding: excluded) {
                out.append(selected)
            }
        }

        return out
    }

    static func prune(
        _ node: any HTMLNode,
        excluding excluded: Set<ScopeIdentifier>?
    ) -> (any HTMLNode)? {
        switch node {
        case let region as HTMLBundledRegion:
            if excluded == nil || excluded?.contains(region.scope) == true {
                return nil
            }

            let kept = prune(
                excluding: excluded,
                from: region.children
            )

            guard !kept.isEmpty else {
                return nil
            }

            return HTMLInlineGroup(kept)

        case let element as HTMLElement:
            let children = prune(
                excluding: excluded,
                from: element.children
            )

            if element.selfClosing {
                return element
            }

            guard !children.isEmpty else {
                return nil
            }

            return HTMLElement(
                element.tag,
                attrs: element.attrs,
                children: children,
                selfClosing: element.selfClosing
            )

        case let inline as HTMLInlineGroup:
            let children = prune(
                excluding: excluded,
                from: inline.children
            )

            guard !children.isEmpty else {
                return nil
            }

            return HTMLInlineGroup(children)

        case let gate as HTMLGate:
            let children = prune(
                excluding: excluded,
                from: gate.children
            )

            guard !children.isEmpty else {
                return nil
            }

            return HTMLGate(
                id: gate.id,
                allow: gate.allowed,
                children: children
            )

        default:
            return node
        }
    }
}
