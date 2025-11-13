import Foundation

public enum ICS {
    // Root document (you can also just use ICSDocument directly if you like)
    public static func document(@ICSBuilder _ body: () -> [any ICSNode]) -> ICSDocument {
        ICSDocument(children: body())
    }

    // VCALENDAR
    public static func calendar(
        prodId: String,
        version: String = "2.0",
        @ICSBuilder _ body: () -> [any ICSNode]
    ) -> ICSDocument {
        let inner = ICSComponent("VCALENDAR", children: [
            ICSProperty("PRODID",  value: .text(prodId)),
            ICSProperty("VERSION", value: .text(version)),
        ] + body())
        return ICSDocument(children: [inner])
    }

    // Generic component helpers
    public static func vEvent(@ICSBuilder _ body: () -> [any ICSNode]) -> ICSComponent {
        ICSComponent("VEVENT", children: body())
    }

    public static func vTodo(@ICSBuilder _ body: () -> [any ICSNode]) -> ICSComponent {
        ICSComponent("VTODO", children: body())
    }

    public static func vAlarm(@ICSBuilder _ body: () -> [any ICSNode]) -> ICSComponent {
        ICSComponent("VALARM", children: body())
    }

    // Common properties
    public static func uid(_ value: String = UUID().uuidString) -> ICSProperty {
        ICSProperty("UID", value: .text(value))
    }

    public static func dtStamp(_ date: Date = Date()) -> ICSProperty {
        ICSProperty("DTSTAMP", value: .date(date, .utc))
    }

    public static func dtStart(
        _ date: Date,
        kind: ICSDateKind = .utc
    ) -> ICSProperty {
        let (value, params) = try! ICSDateFormatter.format(date, as: kind)
        return ICSProperty("DTSTART", parameters: params, value: .raw(value))
    }

    public static func dtEnd(
        _ date: Date,
        kind: ICSDateKind = .utc
    ) -> ICSProperty {
        let (value, params) = try! ICSDateFormatter.format(date, as: kind)
        return ICSProperty("DTEND", parameters: params, value: .raw(value))
    }

    public static func summary(_ text: String) -> ICSProperty {
        ICSProperty("SUMMARY", value: .text(text))
    }

    public static func description(_ text: String) -> ICSProperty {
        ICSProperty("DESCRIPTION", value: .text(text))
    }

    public static func location(_ text: String) -> ICSProperty {
        ICSProperty("LOCATION", value: .text(text))
    }

    public static func prop(
        _ name: String,
        parameters: [String: String] = [:],
        _ value: ICSValue
    ) -> ICSProperty {
        ICSProperty(name, parameters: parameters, value: value)
    }
}
