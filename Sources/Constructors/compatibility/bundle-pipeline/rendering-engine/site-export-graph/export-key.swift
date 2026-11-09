import Foundation

public enum ExportDomain: String, Sendable, Codable, Hashable {
    case document
    case stylesheet
    case snippet
}

public struct ExportKey: Sendable, Codable, Hashable, CustomStringConvertible {
    public let domain: ExportDomain
    public let name: String

    public init(
        domain: ExportDomain,
        name: String
    ) {
        self.domain = domain
        self.name = name
    }

    public var description: String {
        "\(domain.rawValue):\(name)"
    }
}

public extension ExportKey {
    static func document(
        _ name: String
    ) -> Self {
        Self(
            domain: .document,
            name: name
        )
    }

    static func stylesheet(
        _ name: String
    ) -> Self {
        Self(
            domain: .stylesheet,
            name: name
        )
    }

    static func snippet(
        _ name: String
    ) -> Self {
        Self(
            domain: .snippet,
            name: name
        )
    }
}
