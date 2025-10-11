import Foundation

public enum JS {
    public static func call(_ fn: String, _ args: [JSValue] = []) -> String {
        let rendered = args.map { $0.render() }.joined(separator: ",")
        return "\(fn)(\(rendered));"
    }

    public static func assign(_ lhs: String, _ rhs: JSValue) -> String {
        "\(lhs) = \(rhs.render());"
    }

    /// `document.addEventListener('DOMContentLoaded', () => { ... })`
    public static func onDomReady(_ body: String) -> String {
        "document.addEventListener('DOMContentLoaded',()=>{\(body)});"
    }

    /// Delegated event listener: document.addEventListener('click', e => if (e.target.matches(sel)) { ... })
    public static func on(_ event: String, selector: String, body: String) -> String {
        """
        document.addEventListener(\("\(event)".debugDescription), (e) => {
          const el = e.target.closest(\("\(selector)".debugDescription));
          if (el) { \(body) }
        });
        """
    }

    /// Wrap a one-time initializer with a guard by ID or dataset flag
    public static func guardOnce(flagExpr: String, setExpr: String, body: String) -> String {
        "if(!(\(flagExpr))){ \(setExpr) = true; \(body) }"
    }
}
