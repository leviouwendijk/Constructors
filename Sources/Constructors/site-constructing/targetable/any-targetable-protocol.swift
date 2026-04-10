import Foundation
import Path

public protocol Targetable: Sendable {
    var output: StandardPath { get }
}

extension Targetable {}
