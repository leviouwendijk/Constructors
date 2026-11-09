import Path
import Primitives

public protocol PageGraphNode: Sendable {
    associatedtype PageIdentifier: StringIdentifier

    var identifier: PageIdentifier { get }
    var slug: PathSegment? { get }
    var title: String { get }
    var visibility: Set<BuildEnvironment> { get }
    var children: [Self] { get }
}
