import Foundation

public struct HTMLSymbols: Sendable, Equatable {
    public var classes: Set<String>
    public var ids: Set<String>

    public init(classes: Set<String> = [], ids: Set<String> = []) {
        self.classes = classes
        self.ids = ids
    }
}

public enum HTMLSymbolCollector {
    public static func collect(from nodes: HTMLFragment) -> HTMLSymbols {
        var classes = Set<String>()
        var ids = Set<String>()

        for node in nodes {
            collectClasses(from: node, into: &classes)
            collectIDs(from: node, into: &ids)
        }

        return HTMLSymbols(classes: classes, ids: ids)
    }

    private static func collectClasses(
        from node: any HTMLNode,
        into result: inout Set<String>
    ) {
        switch node {
        case let el as HTMLElement:
            for name in el.attrs.classList {
                result.insert(name)
            }
            for child in el.children {
                collectClasses(from: child, into: &result)
            }

        case let inline as HTMLInlineGroup:
            for child in inline.children {
                collectClasses(from: child, into: &result)
            }

        case let gate as HTMLGate:
            for child in gate.children {
                collectClasses(from: child, into: &result)
            }

        default:
            break
        }
    }

    private static func collectIDs(
        from node: any HTMLNode,
        into result: inout Set<String>
    ) {
        switch node {
        case let el as HTMLElement:
            if let id = el.attrs.value(for: "id"), !id.isEmpty {
                result.insert(id)
            }
            for child in el.children {
                collectIDs(from: child, into: &result)
            }

        case let inline as HTMLInlineGroup:
            for child in inline.children {
                collectIDs(from: child, into: &result)
            }

        case let gate as HTMLGate:
            for child in gate.children {
                collectIDs(from: child, into: &result)
            }

        default:
            break
        }
    }
}
