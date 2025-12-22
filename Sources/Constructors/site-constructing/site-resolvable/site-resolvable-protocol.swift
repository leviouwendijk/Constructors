import Path
import ProtocolComponents

public protocol SiteResolvable: Codable, Sendable, CaseIterable, RawRepresentable where RawValue == String {
    func dist() throws -> DistributionPaths
    func copyables_from_public() -> [CopyableResource]
    func site_object() throws -> any SiteObject.Type

    var protocol_component: HTTPProtocolComponent? { get }
    var tld_component: TopLevelDomainComponent? { get }
    var web_root_component: String { get }

    func compose_address(appending path: GenericPath?) -> String
    func address(for identifier: (any TargetIdentifying)?) -> String

    func root_address() -> String

    // based on per-site directory:
    // case dependendent location, can be overwritten by user implementation
    // defaults to a 'www-<self.rawValue>' name
    func default_working_subdirectory() -> String

    // stronger working directory defaults:
    func default_dist_directory(root: DistributionPathsRoot) throws -> DistributionPaths
}
