import Primitives

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

extension TargetMetadata {
    public static func from(
        visibility: Set<BuildEnvironment>
    ) -> TargetMetadata {
        return visibility.contains(.public) ? .default : .blocked
    }

    public static func return_provided_or_initialize(
        metadata: TargetMetadata?,
        visibility: Set<BuildEnvironment>
    ) -> TargetMetadata {
        if let metadata {
            return metadata
        } else {
            return from(visibility: visibility)
        }
    }
}

extension Optional where Wrapped == TargetMetadata {
    public func exists_or_inits(
        visibility: Set<BuildEnvironment>
    ) -> TargetMetadata {
        return TargetMetadata.return_provided_or_initialize(
            metadata: self,
            visibility: visibility
        )
    }
}
