public struct TargetMetadata: Sendable, Equatable {
    public var includeInSitemap: Bool
    public var robots: RobotsDirective

    public init(
        includeInSitemap: Bool = true,
        robots: RobotsDirective = .allow
    ) {
        self.includeInSitemap = includeInSitemap
        self.robots = robots
    }

    public static let `default` = TargetMetadata()

    public static let excludedFromSitemap = TargetMetadata(
        includeInSitemap: false,
        robots: .allow
    )

    public static let blocked = TargetMetadata(
        includeInSitemap: false,
        robots: .disallow
    )

    // public static let snippetDefault = TargetMetadata(
    //     includeInSitemap: false,
    //     robots: .disallow
    // )
}
