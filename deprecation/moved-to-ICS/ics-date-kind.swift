import Foundation
import Primitives

/// How this ICS timestamp should be interpreted.
public enum ICSDateKind: Sendable {
    /// Stored as UTC with trailing "Z"
    case utc

    /// Local wall-clock time with explicit TZID parameter.
    /// Example: `DTSTART;TZID=Europe/Amsterdam:20251113T190000`
    // case local(CustomTimeZone)
    case local(TimeZoneIdentifier)
}

enum ICSDateFormatter {
    static func format(_ date: Date, as kind: ICSDateKind) throws -> (value: String, params: [String:String]) {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyyMMdd'T'HHmmss"
        fmt.locale = Locale(identifier: "en_US_POSIX")

        switch kind {
        case .utc:
            // fmt.timeZone = try CustomTimeZone.utc.set()
            fmt.timeZone = try TimeZoneIdentifier.utc.timezone()
            let value = fmt.string(from: date) + "Z"
            return (value, [:])

        case .local(let zone):
            // fmt.timeZone = try zone.set()
            fmt.timeZone = try zone.timezone()
            let value = fmt.string(from: date)
            return (value, ["TZID": zone.rawValue])
        }
    }
}
