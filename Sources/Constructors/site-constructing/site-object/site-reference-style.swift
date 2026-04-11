import Path

public enum SiteReferenceStyle: Sendable, Equatable {
    case automatic
    case local(PathRelativity = .root)
    case absolute
}

public extension SiteReferenceStyle {
    var localRelativity: PathRelativity {
        switch self {
        case .automatic:
            return .root

        case .local(let relativity):
            return relativity

        case .absolute:
            return .root
        }
    }
}
