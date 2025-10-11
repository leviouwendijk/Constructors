import Foundation

public enum PSQL {
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
