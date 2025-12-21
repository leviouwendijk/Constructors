import Foundation

public enum JSValue: Sendable {
    case str(String), num(Double), bool(Bool), null
    case obj([String: JSValue]), arr([JSValue])

    /// Pass through an identifier or expression (e.g. `window`, `{a:1,...}`)
    case expr(String)
}

public extension JSValue {
    func render() -> String {
        switch self {
        case .str(let s):   return "\"\(s.replacingOccurrences(of: "\"", with: "\\\""))\""
        case .num(let n):   return String(n)
        case .bool(let b):  return b ? "true" : "false"
        case .null:         return "null"
        case .arr(let a):   return "[\(a.map { $0.render() }.joined(separator: ","))]"
        case .obj(let o):
            // deterministically ordered for test stability
            let parts = o.keys.sorted().map { k in "\"\(k)\":\(o[k]!.render())" }
            return "{\(parts.joined(separator: ","))}"
        case .expr(let e):  return e
        }
    }
}
