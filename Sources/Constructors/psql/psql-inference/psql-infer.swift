import Foundation
import Structures

public enum PSQLInfer {
    // Public API
    /// Build a [field: PSQLType] by reflecting a prototype instance.
    public static func types<Row>(from prototype: Row) throws -> [String: PSQLType] {
        var out: [String: PSQLType] = [:]
        let mirror = Mirror(reflecting: prototype)

        for child in mirror.children {
            guard let label = child.label else { continue }
            out[label] = try map(field: label, value: child.value)
        }
        return out
    }

    // Mapping
    /// Map a runtime value (possibly Optional/Array) to a PSQLType.
    private static func map(field: String, value: Any) throws -> PSQLType {
        let m = Mirror(reflecting: value)

        // Optional handling
        if m.displayStyle == .optional {
            if let some = m.children.first?.value {
                return try mapConcrete(type(of: some))
            } else {
                // Strict: unknown wrapped type
                throw InferenceError.ambiguousOptional(field: field)
            }
        }

        // Arrays → infer element type
        if m.displayStyle == .collection {
            let children = Array(m.children)
            guard let first = children.first else {
                throw InferenceError.ambiguousEmptyArray(field: field)
            }
            // Ensure homogenous array (by dynamic type name)
            let firstType = type(of: first.value)
            let hetero = children.dropFirst().contains { type(of: $0.value) != firstType }
            if hetero {
                let types = Set(children.map { String(describing: type(of: $0.value)) })
                throw InferenceError.heterogeneousArray(field: field, types: Array(types).sorted())
            }
            let elem = try mapConcrete(firstType)
            return .array(of: elem)
        }

        // Dictionaries & other containers → we default to jsonb by policy
        if m.displayStyle == .dictionary {
            return .jsonb
        }

        // Concrete scalars/structs
        return try mapConcrete(type(of: value))
    }

    /// Concrete Swift type → PSQLType (no optionals/collections here).
    private static func mapConcrete(_ t: Any.Type) throws -> PSQLType {
        switch t {
        // Text-ish
        case is String.Type, is Substring.Type:
            return .text

        // Signed ints
        case is Int.Type, is Int32.Type:
            return .integer
        case is Int8.Type, is Int16.Type:
            return .smallInt
        case is Int64.Type:
            return .bigInt

        // Unsigned ints (Postgres has no unsigned; map to bigInt conservatively)
        case is UInt.Type, is UInt32.Type, is UInt64.Type:
            return .bigInt
        case is UInt8.Type, is UInt16.Type:
            return .smallInt

        // Floats / decimals
        case is Double.Type:
            return .doublePrecision
        case is Float.Type:
            return .real
        case is Decimal.Type:
            return .numeric(precision: nil, scale: nil)

        // Temporal / misc
        case is Date.Type:
            return .timestamptz
        case is UUID.Type:
            return .uuid
        case is Data.Type:
            return .bytea

        // JSON representations
        case is JSONValue.Type, is [String: JSONValue].Type:
            return .jsonb

        default:
            // Strict by default: no silent jsonb fallback here.
            throw InferenceError.unsupportedShape(field: "<unknown>", valueType: t)
        }
    }
}

extension PSQLInfer {
    public enum InferenceError: Error, LocalizedError {
        case noPrototypeProvided(type: String)
        case unsupportedShape(field: String, valueType: Any.Type)
        case ambiguousOptional(field: String)               // Optional.none and we can't infer inner type
        case ambiguousEmptyArray(field: String)             // [] → unknown element type
        case heterogeneousArray(field: String, types: [String])

        public var errorDescription: String? {
            switch self {
            case .noPrototypeProvided(let type):
                return "No prototype provided for \(type)."
            case .unsupportedShape(let field, let t):
                return "Unsupported field '\(field)' with value type \(t)."
            case .ambiguousOptional(let field):
                return "Cannot infer PSQL type for '\(field)' from nil Optional."
            case .ambiguousEmptyArray(let field):
                return "Cannot infer PSQL array type for '\(field)' from an empty array."
            case .heterogeneousArray(let field, let types):
                return
                    "Cannot infer PSQL array type for '\(field)' because element types vary: \(types.map { String(describing: $0) }.joined(separator: ", "))."
            }
        }

        public var failureReason: String? {
            switch self {
            case .noPrototypeProvided:
                return "Automatic inference requires a prototype instance."
            case .unsupportedShape:
                return "The value’s Swift type has no default PSQL mapping."
            case .ambiguousOptional:
                return "The Optional has no wrapped value at runtime."
            case .ambiguousEmptyArray:
                return "Arrays need at least one element to infer the element type."
            case .heterogeneousArray:
                return "Arrays must contain a single, consistent element type."
            }
        }

        public var recoverySuggestion: String? {
            switch self {
            case .noPrototypeProvided:
                return "Implement psqlTypes() manually, or provide psqlInferencePrototype() on your DTO."
            case .unsupportedShape(let field, _):
                return "Add an override for '\(field)' in psqlTypeOverrides(), or change the DTO field type."
            case .ambiguousOptional(let field):
                return "Provide a non-nil value in the prototype for '\(field)', or add an override."
            case .ambiguousEmptyArray(let field):
                return "Populate the prototype array for '\(field)' with a representative element, or add an override."
            case .heterogeneousArray(let field, _):
                return "Ensure the prototype array for '\(field)' contains elements of a single type, or add an override."
            }
        }
    }
}
