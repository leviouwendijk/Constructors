import Primitives

public extension Site {
    /// How one site is built: its host, other hosts that serve it
    /// (`www.<host>`), and its tree per environment. What a site service
    /// serves and a CLI exports.
    struct Build:
        Sendable
    {
        public let host: String
        public let aliases: [String]
        public let tree: @Sendable (BuildEnvironment) throws -> ArtifactTree

        public init(
            host: String,
            aliases: [String] = [],
            tree: @escaping @Sendable (BuildEnvironment) throws -> ArtifactTree
        ) {
            self.host = host
            self.aliases = aliases
            self.tree = tree
        }
    }
}

public extension Array where Element == Site.Build {
    /// The build serving `host`, by host or alias.
    func build(
        _ host: String
    ) -> Site.Build? {
        first { $0.host == host || $0.aliases.contains(host) }
    }
}
