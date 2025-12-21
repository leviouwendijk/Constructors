public struct NavigationStructure: Sendable {
    public var roots: [NavigationNode]

    public init(roots: [NavigationNode] = []) {
        self.roots = roots
    }
}
