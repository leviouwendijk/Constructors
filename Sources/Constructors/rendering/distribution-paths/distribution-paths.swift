import Foundation
import Milieu

public struct DistributionPaths: Sendable {
    public var test: String
    public var `public`: String
    public var root: DistributionPathsRoot
    
    public init(
        test: String,
        `public`: String,
        root: DistributionPathsRoot
    ) throws {
        self.test = test
        self.public = `public`
        self.root = root

        try resolve()
    }

    internal mutating func resolve() throws -> Void {
        switch root {
        case .manually_provided:
            break
        case .resolve_from_env:
            let websites_root = try DistributionPathsRoot.default_websites_root()
            test = websites_root + test.ensure_leading_slash()
            `public` = websites_root + `public`.ensure_leading_slash()
        }
    }
}

extension String {
    public func ensure_leading_slash() -> String {
        if self.first == "/" { 
            return self 
        } else {
            return "/" + self
        }
    }
}

public enum DistributionPathsRoot: Sendable {
    case manually_provided
    case resolve_from_env

    public static func default_websites_root() throws -> String {
        let replacer = EnvironmentReplacer(replacements: [.home])
        let websites_root = try EnvironmentExtractor.value(.symbol("WEBSITES_ROOT"), replacer: replacer)
        return websites_root
    }
}
