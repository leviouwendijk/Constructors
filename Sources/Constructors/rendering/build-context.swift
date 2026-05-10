import Foundation
import Primitives

public struct BuildContext: Sendable {
    // public let site: Site
    public let site: any SiteResolvable
    // public let distribution: DistributionType
    public let distribution: any BuildEnvironmentReturning

    public let env: BuildEnvironment

    public let showGates: Bool
    public let verbose: Bool

    public let baseURL: URL

    public let site_object: any SiteObject.Type

    public init(
        site: any SiteResolvable,
        distribution: any BuildEnvironmentReturning,
        showGates: Bool,
        verbose: Bool
    ) throws {
        self.site = site
        self.distribution = distribution
        self.env = distribution.env()
        self.showGates = showGates
        self.verbose = verbose
        // self.baseURL = try distribution.base_url(for: site)
        self.baseURL = try env.base_url(for: site)
        self.site_object = try site.site_object()
    }
}
