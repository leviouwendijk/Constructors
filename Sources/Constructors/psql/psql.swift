import Foundation
import Structures

public enum PSQL {
    public enum SQLBindValue: Sendable {
      case null
      case text(String)
      case bool(Bool)
      case int64(Int64)
      case double(Double)
      case date(Date)           // you decide text vs binary
      case uuid(UUID)
      case decimal(Decimal)
      case json(Data)           // already-encoded JSON
      case jsonb(Data)
      case bytea(Data)
      case inet(String)
      case array([SQLBindValue], element: PSQLType?) // typed pg array
    }

    public typealias SQL = String

    /// Sendable-erased Encodable for driver binds.
    public struct SQLBind: Encodable, Sendable {
        private let _encode: @Sendable (Encoder) throws -> Void
        public init<T: Encodable & Sendable>(_ value: T) {
            self._encode = { encoder in try value.encode(to: encoder) }
        }
        public func encode(to encoder: Encoder) throws { try _encode(encoder) }
    }

    public struct RenderedSQL: Sendable {
        public let sql: SQL
        public let binds: [SQLBind]
        public init(_ sql: SQL, _ binds: [SQLBind]) { self.sql = sql; self.binds = binds }
    }
}
