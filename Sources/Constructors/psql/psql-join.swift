import Foundation

extension PSQL {
    public enum JoinKind: String, Sendable { case inner = "INNER JOIN", left = "LEFT JOIN", right = "RIGHT JOIN" }

    public struct Join: SQLRenderable {
        public let kind: JoinKind
        public let table: String
        public let on: any SQLRenderable
        public init(_ kind: JoinKind, _ table: String, on: any SQLRenderable) {
            self.kind = kind; self.table = table; self.on = on
        }
        public func render(_ ctx: inout SQLRenderContext) -> String {
            // "\(kind.rawValue) \"\(table)\" ON \(on.render(&ctx))"
            "\(kind.rawValue) \(Ident.table(table).render(&ctx)) ON \(on.render(&ctx))"
        }
    }

    public static func join(_ kind: JoinKind, table: Ident, on: any SQLRenderable) -> Join {
        .init(kind, table.value, on: on)
    }
}
