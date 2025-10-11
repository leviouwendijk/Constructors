import Foundation

extension PSQL {
    public protocol SQLRenderable: Sendable {
        func render(_ ctx: inout SQLRenderContext) -> String
    }

    public struct SQLRenderContext: Sendable {
        public var binds: [SQLBind] = []
        public init() {}

        @inline(__always) public mutating func bind<T: Encodable & Sendable>(_ v: T) -> String {
            binds.append(SQLBind(v))
            return "$\(binds.count)"
        }
    }
}

extension Array where Element == any PSQL.SQLRenderable {
    func joined(_ sep: String, _ ctx: inout PSQL.SQLRenderContext) -> String {
        self.map { $0.render(&ctx) }.joined(separator: sep)
    }
}

