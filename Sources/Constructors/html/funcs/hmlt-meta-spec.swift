import Foundation

public enum HTMLMetaSpec: Sendable {
    case charset(String = "UTF-8")
    case viewport(String = "width=device-width, initial-scale=1.0")
    case robots(String = "index, follow")
    case httpEquiv(equiv: String, content: String)
    case name(name: String, content: String)                 // generic name=...
    case property(property: String, content: String)         // OG, etc. (property=)
    case twitter(name: String, content: String)              // twitter:* as name=...
    case themeColor(String)                                  // <meta name="theme-color" ...>
    case contentLanguage(String)                             // <meta http-equiv="Content-Language" ...>

    public func attributes() -> HTMLAttribute {
        switch self {
        case .charset(let v):
            let a: HTMLAttribute = ["charset": v]
            return a

        case .viewport(let v):
            let a: HTMLAttribute = ["name":"viewport", "content": v]
            return a

        case .robots(let v):
            let a: HTMLAttribute = ["name":"robots", "content": v]
            return a

        case .httpEquiv(let equiv, let content):
            let a: HTMLAttribute = ["http-equiv": equiv, "content": content]
            return a

        case .name(let name, let content):
            let a: HTMLAttribute = ["name": name, "content": content]
            return a

        case .property(let property, let content):
            let a: HTMLAttribute = ["property": property, "content": content]
            return a

        case .twitter(let name, let content):
            let a: HTMLAttribute = ["name": name, "content": content]
            return a

        case .themeColor(let color):
            let a: HTMLAttribute = ["name":"theme-color", "content": color]
            return a

        case .contentLanguage(let lang):
            let a: HTMLAttribute = ["http-equiv":"Content-Language", "content": lang]
            return a
        }
    }
}
