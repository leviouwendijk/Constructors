public struct NavigationInterface: Sendable {
    public var roots: [NavigationNode]

    public init(roots: [NavigationNode] = []) {
        self.roots = roots
    }
}
