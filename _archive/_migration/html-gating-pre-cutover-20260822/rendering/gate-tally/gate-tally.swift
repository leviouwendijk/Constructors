import Primitives
import HTML

// Lightweight collector for gate events (rendered vs skipped)
public struct GateTally: Sendable {
    public var rendered: [GateEvent] = []
    public var skipped:  [GateEvent] = []

    public mutating func record(_ e: GateEvent) {
        if e.rendered { rendered.append(e) } else { skipped.append(e) }
    }

    // func prettySummary(site: Site, page: String, env: BuildEnvironment) -> String {
    public func prettySummary(
        site: any SiteResolvable,
        page: String,
        env: BuildEnvironment
    ) -> String {
        func fmtSet(_ s: Set<BuildEnvironment>) -> String {
            let order: [BuildEnvironment] = [.local, .test, .public]
            return "[" + order.filter(s.contains).map { "\($0)" }.joined(separator: ", ") + "]"
        }

        var out = ""
        if !rendered.isEmpty || !skipped.isEmpty {
            out += "gates \(site.rawValue)/\(page) (env \(env))\n"
        }

        if !skipped.isEmpty {
            out += "  ⤫ skipped (\(skipped.count)):\n"
            for e in skipped {
                let label = e.id ?? "«anonymous»"
                out += "    - \(label) allow \(fmtSet(e.allowed))\n"
            }
        }

        if !rendered.isEmpty {
            out += "  ✓ rendered (\(rendered.count)):\n"
            for e in rendered {
                let label = e.id ?? "«anonymous»"
                out += "    - \(label) allow \(fmtSet(e.allowed))\n"
            }
        }

        if !out.isEmpty { out += "\n" }

        return out
    }
}
