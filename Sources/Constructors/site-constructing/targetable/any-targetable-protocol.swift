import Foundation
import Path

public protocol Targetable: Sendable {
    var output: GenericPath { get }
}

extension Targetable {}
