import Foundation
import Structures

public enum PSQL {
    public enum SQLBindValue: Sendable, Encodable {
        case null
        case text(String)
        case bool(Bool)
        case int64(Int64)
        case double(Double)
        case date(Date)  // you decide text vs binary
        case uuid(UUID)
        case decimal(Decimal)
        case json(Data)  // already-encoded JSON
        case jsonb(Data)
        case bytea(Data)
        case inet(String)
        case array([SQLBindValue], element: PSQLType?)  // typed pg array

        public func encode(to encoder: Encoder) throws {
            var c = encoder.singleValueContainer()
            switch self {
            case .null:
                try c.encodeNil()
            case .text(let s):
                try c.encode(s)
            case .bool(let b):
                try c.encode(b)
            case .int64(let i):
                try c.encode(i)
            case .double(let d):
                try c.encode(d)
            case .date(let d):
                // encode as ISO8601 string for round-trip safety
                let f = ISO8601DateFormatter()
                f.formatOptions = [
                    .withInternetDateTime, .withFractionalSeconds, .withColonSeparatorInTimeZone,
                ]
                f.timeZone = TimeZone(secondsFromGMT: 0)  // UTC
                try c.encode(f.string(from: d))
            case .uuid(let u):
                try c.encode(u.uuidString)
            case .decimal(let dec):
                try c.encode(dec.description)  // preserve precision via text
            case .json(let data), .jsonb(let data):
                // encode the JSON bytes as a UTF-8 string; boundary will bind as text
                try c.encode(String(data: data, encoding: .utf8) ?? "null")
            case .bytea(let data):
                // safe JSON encoding; boundary can choose how to bind
                try c.encode(data.base64EncodedString())
            case .inet(let s):
                try c.encode(s)
            case .array(let items, _):
                try c.encode(items)  // elements are Encodable (self)
            }
        }
    }

    public typealias SQL = String

    // /// Sendable-erased Encodable for driver binds.
    // public struct SQLBind: Encodable, Sendable {
    //     private let _encode: @Sendable (Encoder) throws -> Void
    //     public init<T: Encodable & Sendable>(_ value: T) {
    //         self._encode = { encoder in try value.encode(to: encoder) }
    //     }
    //     public func encode(to encoder: Encoder) throws { try _encode(encoder) }
    // }

    public struct SQLBind: Encodable, Sendable {
        private let _encode: @Sendable (Encoder) throws -> Void
        public let value: SQLBindValue?
        public let hint: PSQLType?  // optional cast/type info for the boundary

        public init<T: Encodable & Sendable>(_ v: T, hint: PSQLType? = nil) {
            self._encode = { enc in try v.encode(to: enc) }
            self.value = nil
            self.hint = hint
        }

        public init(_ v: SQLBindValue, hint: PSQLType? = nil) {
            self._encode = { enc in try v.encode(to: enc) }  // trivial Encodable shim if you like
            self.value = v
            self.hint = hint
        }

        public func encode(to e: Encoder) throws { try _encode(e) }

        // convenience
        static func text(_ s: String, hint: PSQLType? = .text) -> Self {
            .init(.text(s), hint: hint)
        }
        static func bool(_ b: Bool, hint: PSQLType? = .boolean) -> Self {
            .init(.bool(b), hint: hint)
        }
        static func int64(_ i: Int64, hint: PSQLType? = .bigInt) -> Self {
            .init(.int64(i), hint: hint)
        }
        static func double(_ d: Double, hint: PSQLType? = .doublePrecision) -> Self {
            .init(.double(d), hint: hint)
        }
        static func date(_ d: Date, hint: PSQLType? = .timestamptz) -> Self {
            .init(.date(d), hint: hint)
        }
        static func uuid(_ u: UUID, hint: PSQLType? = .uuid) -> Self { .init(.uuid(u), hint: hint) }
        static func json(_ data: Data, hint: PSQLType? = .jsonb) -> Self {
            .init(.jsonb(data), hint: hint)
        }
        static func array(_ xs: [PSQL.SQLBindValue], element: PSQLType) -> Self {
            .init(.array(xs, element: element), hint: .array(of: element))
        }
    }

    public struct RenderedSQL: Sendable {
        public let sql: SQL
        public let binds: [SQLBind]
        public init(_ sql: SQL, _ binds: [SQLBind]) { self.sql = sql; self.binds = binds }
    }
}
