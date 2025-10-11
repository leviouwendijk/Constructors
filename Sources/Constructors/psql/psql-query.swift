import Foundation

extension PSQL {
    public protocol SQLQuery: SQLRenderable {
        func build() -> RenderedSQL
    }

    public struct Select: SQLQuery {
        public let columns: [any SQLRenderable]
        public let table: String
        public var joins: [Join] = []
        public var predicate: (any SQLRenderable)?
        public var order: [any SQLRenderable] = []
        public var limitValue: Int?
        public var offsetValue: Int?
        public var distinct: Bool = false
        public var ctes: [(String, Select)] = []
        public var forUpdate: Bool = false

        public init(_ cols: [any SQLRenderable], from table: String) {
            self.columns = cols; self.table = table
        }

        public static func make(_ cols: [any SQLRenderable], from table: String) -> Select {
            .init(cols, from: table)
        }

        public func with(_ name: String, as sel: Select) -> Select { var c = self; c.ctes.append((name, sel)); return c }
        public func `where`(@BoolExprBuilder _ b: () -> [any SQLRenderable]) -> Select { var c = self; c.predicate = Op.group(b()); return c }
        public func join(_ j: Join) -> Select { var c = self; c.joins.append(j); return c }

        public func orderBy(_ items: [any SQLRenderable]) -> Select { var c = self; c.order = items; return c }
        public func orderBy(_ items: any SQLRenderable...) -> Select { orderBy(items) }
        public func orderByIdent(_ items: PSQL.Order...) -> Select {
            orderBy(items as [any SQLRenderable])
        }

        public func limit(_ n: Int) -> Select { var c = self; c.limitValue = n; return c }
        public func offset(_ n: Int) -> Select { var c = self; c.offsetValue = n; return c }
        public func distinct(_ d: Bool = true) -> Select { var c = self; c.distinct = d; return c }
        public func lockForUpdate(_ yes: Bool = true) -> Select { var c = self; c.forUpdate = yes; return c }

        public func render(_ ctx: inout SQLRenderContext) -> String {
            var parts: [String] = []
            if !ctes.isEmpty {
                let cteSQL = ctes.map { name, sel -> String in
                    var c = SQLRenderContext(); let s = sel.render(&c)
                    ctx.binds.append(contentsOf: c.binds)
                    return #""\#(name)" AS (\#(s))"#
                }.joined(separator: ", ")
                parts.append("WITH \(cteSQL)")
            }
            parts.append("SELECT \(distinct ? "DISTINCT " : "")\(columns.joined(", ", &ctx))")
            parts.append("FROM \"\(table)\"")
            if !joins.isEmpty { parts.append(joins.map { $0.render(&ctx) }.joined(separator: " ")) }
            if let p = predicate { parts.append("WHERE \(p.render(&ctx))") }
            if !order.isEmpty { parts.append("ORDER BY " + order.joined(", ", &ctx)) }
            if let l = limitValue { parts.append("LIMIT \(l)") }
            if let o = offsetValue { parts.append("OFFSET \(o)") }
            if forUpdate { parts.append("FOR UPDATE") }
            return parts.joined(separator: " ")
        }

        public func build() -> RenderedSQL {
            var c = SQLRenderContext()
            let s = render(&c)
            return .init(s, c.binds)
        }
    }

    public struct Insert: SQLQuery {
        public let table: String
        public let columns: [String]
        public var rows: [[any Encodable & Sendable]] = []
        public var onConflictSpec: (any SQLRenderable)? = nil   // <- typed

        // @available(*, deprecated, message: "Use typed OnConflict instead")
        // public var onConflictString: String? = nil              // <- legacy

        public var returningCols: [any SQLRenderable] = []

        public init(into table: String, columns: [String]) {
            self.table = table; self.columns = columns
        }
        public static func make(into table: String, columns: [String]) -> Insert { .init(into: table, columns: columns) }

        public func values(_ row: [any Encodable & Sendable]) -> Insert { var c = self; c.rows.append(row); return c }
        public func onConflict(_ spec: OnConflict) -> Insert { var c = self; c.onConflictSpec = spec; return c }

        // @available(*, deprecated, message: "Use typed OnConflict instead")
        // public func onConflict(_ raw: String) -> Insert { var c = self; c.onConflictString = raw; return c }

        public func returning(_ cols: [any SQLRenderable]) -> Insert { var c = self; c.returningCols = cols; return c }

        public func render(_ ctx: inout SQLRenderContext) -> String {
            let cols = columns.map { #""\#($0)""# }.joined(separator: ", ")
            let vals = rows.map { r -> String in
                let params = r.map { ctx.bind($0) }.joined(separator: ", ")
                return "(\(params))"
            }.joined(separator: ", ")
            var sql = "INSERT INTO \"\(table)\" (\(cols)) VALUES \(vals)"
            if let oc = onConflictSpec {
                sql += " " + oc.render(&ctx)
            } 
            // else if let legacy = onConflictString {
            //     sql += " ON CONFLICT \(legacy)"
            // }
            if !returningCols.isEmpty { sql += " RETURNING \(returningCols.joined(", ", &ctx))" }
            return sql
        }

        public func build() -> RenderedSQL { var c = SQLRenderContext(); return .init(render(&c), c.binds) }
    }

    public struct Update: SQLQuery {
        public let table: String
        public var sets: [(String, any Encodable & Sendable)] = []
        public var predicate: (any SQLRenderable)?
        public var returningCols: [any SQLRenderable] = []

        public init(_ table: String) { self.table = table }
        public static func make(_ table: String) -> Update { .init(table) }

        public func set(_ k: String, _ v: any Encodable & Sendable) -> Update { var c = self; c.sets.append((k, v)); return c }
        public func `where`(@BoolExprBuilder _ b: () -> [any SQLRenderable]) -> Update { var c = self; c.predicate = Op.group(b()); return c }
        public func returning(_ cols: [any SQLRenderable]) -> Update { var c = self; c.returningCols = cols; return c }

        public func render(_ ctx: inout SQLRenderContext) -> String {
            let assigns = sets.map { #""\#($0.0)" = \#(ctx.bind($0.1))"# }.joined(separator: ", ")
            var sql = "UPDATE \"\(table)\" SET \(assigns)"
            if let p = predicate { sql += " WHERE \(p.render(&ctx))" }
            if !returningCols.isEmpty { sql += " RETURNING \(returningCols.joined(", ", &ctx))" }
            return sql
        }

        public func build() -> RenderedSQL { var c = SQLRenderContext(); return .init(render(&c), c.binds) }
    }

    public struct Delete: SQLQuery {
        public let table: String
        public var predicate: (any SQLRenderable)?

        public init(from table: String) { self.table = table }
        public static func make(from table: String) -> Delete { .init(from: table) }

        public func `where`(@BoolExprBuilder _ b: () -> [any SQLRenderable]) -> Delete { var c = self; c.predicate = Op.group(b()); return c }

        public func render(_ ctx: inout SQLRenderContext) -> String {
            var sql = "DELETE FROM \"\(table)\""
            if let p = predicate { sql += " WHERE \(p.render(&ctx))" }
            return sql
        }

        public func build() -> RenderedSQL { var c = SQLRenderContext(); return .init(render(&c), c.binds) }
    }

    public enum OnConflict: SQLRenderable {
        case doNothing(columns: [Ident]? = nil, constraint: String? = nil)
        case doUpdate(columns: [Ident], set: [(String, any Encodable & Sendable)])

        public func render(_ ctx: inout SQLRenderContext) -> String {
            switch self {
            case .doNothing(let cols, let constraint):
                var s = "ON CONFLICT "
                if let cols, !cols.isEmpty {
                    s += "(" + cols.map { $0.render(&ctx) }.joined(separator: ", ") + ") DO NOTHING"
                } else if let c = constraint {
                    s += "ON CONSTRAINT \(Ident(c, kind: .alias).render(&ctx)) DO NOTHING"
                } else {
                    s = "ON CONFLICT DO NOTHING"
                }
                return s

            case .doUpdate(let cols, let set):
                let target = "(" + cols.map { $0.render(&ctx) }.joined(separator: ", ") + ")"
                let assigns = set.map { #""\#($0.0)" = EXCLUDED."\#($0.0)""# }.joined(separator: ", ")
                return "ON CONFLICT \(target) DO UPDATE SET \(assigns)"
            }
        }
    }
}
