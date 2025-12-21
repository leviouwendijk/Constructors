import Foundation

public enum SiteObjectKeyError: Error, CustomStringConvertible {
    case duplicatePageKey(site: Any.Type, key: String)
    case duplicateStylesheetKey(site: Any.Type, key: String)
    case duplicateSnippetKey(site: Any.Type, key: String)

    public var description: String {
        switch self {
        case let .duplicatePageKey(site, key):
            return "Duplicate page key '\(key)' in \(site)"
        case let .duplicateStylesheetKey(site, key):
            return "Duplicate stylesheet key '\(key)' in \(site)"
        case let .duplicateSnippetKey(site, key):
            return "Duplicate snippet key '\(key)' in \(site)"
        }
    }
}
