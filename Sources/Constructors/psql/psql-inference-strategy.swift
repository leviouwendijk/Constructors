import Foundation

public enum PSQLTypeResolutionError: Error, LocalizedError {
    case unsupportedStrategy

    public var errorDescription: String? { 
        switch self {
        case .unsupportedStrategy:
            return "Unsupported PSQL type strategy." 
        }
    }
}

public enum PSQLTypeInferenceStrategy<Row> {
    case manual([String: PSQLType])
    case inferred(prototype: Row, overrides: [String: PSQLType] = [:])

    public func resolve() throws -> [String: PSQLType] {
        switch self {
        case .manual(let map):
            return map
        case .inferred(let proto, let overrides):
            var types = try PSQLInfer.types(from: proto)
            for (k, v) in overrides { types[k] = v }
            return types
        }
    }
}
