import Foundation

@inline(__always)
public func htmlEscape(_ s: String) -> String {
    var out = ""
    out.reserveCapacity(s.count + s.count/8)
    for ch in s {
        switch ch {
        case "&":  out += "&amp;"
        case "<":  out += "&lt;"
        case ">":  out += "&gt;"
        case "\"": out += "&quot;"
        case "'":  out += "&#39;"
        default:   out.append(ch)
        }
    }
    return out
}
