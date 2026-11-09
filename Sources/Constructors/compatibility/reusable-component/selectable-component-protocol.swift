import DSL

public protocol SelectableComponent: ReusableComponent {
    associatedtype SelectorNamespace
    associatedtype Selectors = BlockSelectorAPI<SelectorNamespace>

    static var block: String { get }
    static var selectors: Selectors { get }
}

public extension SelectableComponent
where Selectors == BlockSelectorAPI<SelectorNamespace> {
    static var selectors: Selectors {
        BlockSelectorAPI(
            block: block
        )
    }
}

extension SelectableComponent {
    public var selectors: Self.Selectors {
        Self.selectors
    }
}
