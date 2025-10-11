import Foundation

extension PSQL {
    public enum IdentKind: Sendable { case table, column, alias }

    public struct Ident: SQLRenderable {
        public let value: String
        public let kind: IdentKind
        static let rx = try! NSRegularExpression(
            pattern: #"^[A-Za-z_][A-Za-z0-9_]*(?:\.[A-Za-z_][A-Za-z0-9_]*)?$"#
        )

        public init(_ value: String, kind: IdentKind) {
            precondition(
                Self.rx
                    .firstMatch(
                        in: value,
                        range: NSRange(
                                location: 0,
                                length: value.utf16.count
                            )
                        ) != nil,
                        "Unsafe identifier: \(value)"
                    )
            self.value = value; self.kind = kind
        }

        public func render(_ ctx: inout SQLRenderContext) -> String {
            value.split(separator: ".").map { #""\#($0)""# }.joined(separator: ".")
        }

        public static func table(_ s: String)  -> Ident { .init(s, kind: .table) }
        public static func column(_ s: String) -> Ident { .init(s, kind: .column) }
        public static func alias(_ s: String)  -> Ident { .init(s, kind: .alias)  }
    }

    // MARK: Atoms
    public struct Col: SQLRenderable {
        public let name: String

        public init(_ name: String) { 
            precondition(!name.contains("."), "Use PSQL.Ident.column(\"u.col\") for dotted identifiers")
            self.name = name 
        }

        public func render(_ ctx: inout SQLRenderContext) -> String { #""\#(name)""# }
    }

    public struct Param: SQLRenderable {
        public let encode: @Sendable (inout SQLRenderContext) -> String
        public init<T: Encodable & Sendable>(_ value: T) {
            self.encode = { ctx in ctx.bind(value) }
        }
        public func render(_ ctx: inout SQLRenderContext) -> String { encode(&ctx) }
    }

    public struct Lit: SQLRenderable {
        public let raw: String
        public init(_ raw: String) { self.raw = raw }
        public func render(_ ctx: inout SQLRenderContext) -> String { raw }
    }

    public struct Func: SQLRenderable {
        public let name: String
        public let args: [any SQLRenderable]
        public init(_ name: String, _ args: [any SQLRenderable]) { self.name = name; self.args = args }
        public func render(_ ctx: inout SQLRenderContext) -> String { "\(name)(\(args.joined(", ", &ctx)))" }
    }

    public enum Op: SQLRenderable {
        case bin(any SQLRenderable, String, any SQLRenderable)
        case not(any SQLRenderable)
        case group([any SQLRenderable])

        public func render(_ ctx: inout SQLRenderContext) -> String {
            switch self {
            case let .bin(l, o, r): return "(\(l.render(&ctx)) \(o) \(r.render(&ctx)))"
            case let .not(e):       return "(NOT \(e.render(&ctx)))"
            case let .group(list):  return "(\(list.joined(" AND ", &ctx)))"
            }
        }
    }

    public enum Order: SQLRenderable {
        case asc(Ident), desc(Ident)
        public func render(_ ctx: inout SQLRenderContext) -> String {
            switch self {
            case .asc(let id):  return "\(id.render(&ctx)) ASC"
            case .desc(let id): return "\(id.render(&ctx)) DESC"
            }
        }
    }

    // MARK: Namespace helpers (mirror HTML.* style)
    @inline(__always) public static func col(_ n: String) -> Col { Col(n) }
    @inline(__always) public static func val<T: Encodable & Sendable>(_ v: T) -> Param { Param(v) }
    @inline(__always) public static func func_(_ name: String, _ args: [any SQLRenderable]) -> Func { Func(name, args) }

    /// Escape hatch. If `strict` is true (default), we **precondition-fail** when we detect likely literals
    /// that should be parameters (single-quoted strings, numeric literals, or inline casts).
    @inline(__always)
    public static func unsafeRawInjection(_ s: String, strict: Bool = true) -> Lit {
        if strict {
            // Heuristic: single-quoted literal, numeric bare literal, ::type cast, or comment marker.
            let patterns = [
                #"'.*?'"#,                 // single-quoted literals
                #"\b\d+(\.\d+)?\b"#,       // plain numbers
                #"::[A-Za-z_][A-Za-z0-9_]*"#, // explicit casts
                #"--"#,                    // line comment
                #"/\*"#                    // block comment
            ]
            let rx = try! NSRegularExpression(pattern: "(" + patterns.joined(separator: "|") + ")", options: [.dotMatchesLineSeparators])
            if rx.firstMatch(in: s, range: NSRange(location: 0, length: s.utf16.count)) != nil {
                preconditionFailure("unsafeRawInjection(strict:true) blocked likely unparameterized literal. Use PSQL.val(...) binds instead or pass strict:false explicitly.")
            }
        }
        return Lit(s)
    }

    // Comparisons
    public static func equals(_ l: any SQLRenderable, _ r: any SQLRenderable) -> Op { .bin(l, "=", r) }
    public static func notEquals(_ l: any SQLRenderable, _ r: any SQLRenderable) -> Op { .bin(l, "<>", r) }
    public static func gt(_ l: any SQLRenderable, _ r: any SQLRenderable) -> Op { .bin(l, ">", r) }
    public static func gte(_ l: any SQLRenderable, _ r: any SQLRenderable) -> Op { .bin(l, ">=", r) }
    public static func lt(_ l: any SQLRenderable, _ r: any SQLRenderable) -> Op { .bin(l, "<", r) }
    public static func lte(_ l: any SQLRenderable, _ r: any SQLRenderable) -> Op { .bin(l, "<=", r) }

    // Text ops
    @inline(__always) public static func like(_ l: any SQLRenderable, _ r: any SQLRenderable) -> Op { .bin(l, "LIKE", r) }
    @inline(__always) public static func ilike(_ l: any SQLRenderable, _ r: any SQLRenderable) -> Op { .bin(l, "ILIKE", r) }

    // JSONB
    @inline(__always) public static func jsonbContains(_ l: any SQLRenderable, _ r: any SQLRenderable) -> Op { .bin(l, "@>", r) }

    // Bool combinators
    public static func and(_ l: Op, _ r: Op) -> Op { .group([l, r]) }
    public static func or(_ l: Op, _ r: Op) -> Op { .bin(l, "OR", r) }

    /// Render a list of `$n` params and append all binds to the current context.
    public struct ParamsList: SQLRenderable {
        public let values: [any Encodable & Sendable]
        public init(_ values: [any Encodable & Sendable]) { self.values = values }
        public func render(_ ctx: inout SQLRenderContext) -> String {
            guard !values.isEmpty else {
                // Valid SQL and evaluates to UNKNOWN (falsey) in comparisons like `col IN (NULL)`
                return "(NULL)"
            }
            let start = ctx.binds.count
            for v in values { _ = ctx.bind(v) }
            let ph = (1...values.count).map { "$\(start + $0)" }.joined(separator: ", ")
            return "(\(ph))"
        }
    }

    /// `l IN ($1, $2, ...)` with proper binding expansion
    @inline(__always)
    public static func `in`(_ l: any SQLRenderable, _ values: [any Encodable & Sendable]) -> Op {
        .bin(l, "IN", ParamsList(values))
    }

    /// `l IN (subquery)`
    @inline(__always)
    public static func inSubquery(_ l: any SQLRenderable, _ sub: any SQLRenderable) -> Op {
        .bin(l, "IN", sub)
    }

    public static func any(_ l: any SQLRenderable, _ arrParam: Param) -> Op { .bin(l, "= ANY", arrParam) }
    public static func all(_ l: any SQLRenderable, _ arrParam: Param) -> Op { .bin(l, "= ALL", arrParam) }

    /// Renders `l BETWEEN a AND b` safely in the *same* context.
    public struct BetweenPair: SQLRenderable {
        let a: any SQLRenderable
        let b: any SQLRenderable
        public func render(_ ctx: inout SQLRenderContext) -> String {
            "\(a.render(&ctx)) AND \(b.render(&ctx))"
        }
    }
    @inline(__always)
    public static func between(_ l: any SQLRenderable, _ a: Param, _ b: Param) -> Op {
        .bin(l, "BETWEEN", BetweenPair(a: a, b: b))
    }

    public struct Exists: SQLRenderable {
        let sub: any SQLRenderable
        public init(_ sub: any SQLRenderable) { self.sub = sub }
        public func render(_ ctx: inout SQLRenderContext) -> String { "EXISTS (\(sub.render(&ctx)))" }
    }

    // CASE WHEN … THEN … [ELSE …] END
    public struct CaseWhen: SQLRenderable {
        let whens: [(any SQLRenderable, any SQLRenderable)]
        let elseExpr: (any SQLRenderable)?
        public init(_ whens: [(any SQLRenderable, any SQLRenderable)], else elseExpr: (any SQLRenderable)? = nil) {
            self.whens = whens; self.elseExpr = elseExpr
        }
        public func render(_ ctx: inout SQLRenderContext) -> String {
            var out = "CASE"
            for (cond, expr) in whens {
                out += " WHEN \(cond.render(&ctx)) THEN \(expr.render(&ctx))"
            }
            if let e = elseExpr { out += " ELSE \(e.render(&ctx))" }
            out += " END"
            return out
        }
    }

    // Order helpers
    @inline(__always) public static func asc(_ id: Ident) -> Order { .asc(id) }
    @inline(__always) public static func desc(_ id: Ident) -> Order { .desc(id) }
}
