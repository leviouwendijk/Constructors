import Foundation

public enum ICSValue: Sendable {
    case text(String)
    case int(Int)
    case date(Date, ICSDateKind)
    /// For cases where you already have a fully formatted string.
    case raw(String)
}

extension ICSValue {
    func render() -> String {
        switch self {
        case .text(let t):
            return ICSValue.escapeText(t)

        case .int(let i):
            return String(i)

        case .date(let d, let kind):
            // format(_:as:) is throwing; we treat CustomTimeZone enum as infallible here.
            let (value, _) = try! ICSDateFormatter.format(d, as: kind)
            return value

        case .raw(let s):
            return s
        }
    }

    static func escapeText(_ text: String) -> String {
        text
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: ";",  with: "\\;")
            .replacingOccurrences(of: ",",  with: "\\,")
            .replacingOccurrences(of: "\n", with: "\\n")
    }
}

public struct ICSProperty: ICSNode {
    public var name: String
    /// Parameters after the name: `;TZID=Europe/Amsterdam;ROLE=REQ-PARTICIPANT`
    public var parameters: [String: String]
    public var value: ICSValue

    public init(
        _ name: String,
        parameters: [String: String] = [:],
        value: ICSValue
    ) {
        self.name = name
        self.parameters = parameters
        self.value = value
    }

    public func lines(options: ICSRenderOptions) -> [String] {
        let paramString = parameters
            .sorted { $0.key < $1.key } // stable, deterministic
            .map { "\($0.key)=\($0.value)" }
            .joined(separator: ";")

        let prefix: String
        if paramString.isEmpty {
            prefix = name
        } else {
            prefix = "\(name);\(paramString)"
        }

        let base = "\(prefix):\(value.render())"
        return foldIfNeeded(base, options: options)
    }

    private func foldIfNeeded(_ line: String, options: ICSRenderOptions) -> [String] {
        guard options.foldLines, line.count > options.maxLineLength else {
            return [line]
        }
        var result: [String] = []
        var remaining = line[...]
        let max = options.maxLineLength

        while remaining.count > max {
            let idx = remaining.index(remaining.startIndex, offsetBy: max)
            let head = remaining[..<idx]
            result.append(String(head))
            remaining = remaining[idx...]
            // Continuation lines start with a space
            remaining = Substring(" " + remaining)
        }
        result.append(String(remaining))
        return result
    }
}
