import Foundation

public struct ICSComponent: ICSNode {
    public var name: String      // VCALENDAR, VEVENT, VTODO, VALARM, ...
    public var children: [any ICSNode]

    public init(
        _ name: String,
        children: [any ICSNode] = []
    ) {
        self.name = name
        self.children = children
    }

    public func lines(options: ICSRenderOptions) -> [String] {
        var out: [String] = []
        out.append("BEGIN:\(name)")
        for child in children {
            out.append(contentsOf: child.lines(options: options))
        }
        out.append("END:\(name)")
        return out
    }
}
