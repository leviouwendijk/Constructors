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

public enum PSQLTypeInferenceStrategy<Row: Decodable> {
    case manual([String: PSQLType])
    case inferred(prototype: Row, overrides: [String: PSQLType] = [:])
    case auto(overrides: [String: PSQLType] = [:])

    public func resolve() throws -> [String: PSQLType] {
        switch self {
        case .manual(let map):
            return map
        case .inferred(let proto, let overrides):
            var types = try PSQLInfer.types(from: proto)
            for (k, v) in overrides { types[k] = v }
            return types
        case .auto(let overrides):
            let proto = try PSQLInferPrototype.make(Row.self)
            var types = try PSQLInfer.types(from: proto)
            for (k, v) in overrides { types[k] = v }
            return types
        }
    }
}
