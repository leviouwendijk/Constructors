public struct NavigationNode: Sendable, Hashable {
    public var label: String
    public var path: String?
    public var children: [NavigationNode]

    public init(
        label: String,
        path: String? = nil,
        children: [NavigationNode] = []
    ) {
        self.label = label
        self.path = path
        self.children = children
    }

    public var isLeaf: Bool {
        path != nil && children.isEmpty
    }

    public var hasChildren: Bool {
        !children.isEmpty
    }
}
