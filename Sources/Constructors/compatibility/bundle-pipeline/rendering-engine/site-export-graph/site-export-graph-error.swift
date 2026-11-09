import Foundation

public enum SiteExportGraphError: Error, LocalizedError, Sendable, Equatable {
    case exportNotFound(
        key: ExportKey,
        siteID: String
    )

    case exportHasNoRoute(
        key: ExportKey
    )

    case siteMismatch(
        expected: String,
        actual: String
    )

    public var errorDescription: String? {
        switch self {
        case .exportNotFound(
            let key,
            let siteID
        ):
            return "No evaluated export with key '\(key)' exists in graph '\(siteID)'."

        case .exportHasNoRoute(let key):
            return "Export '\(key)' has no primary route/output."

        case .siteMismatch(
            let expected,
            let actual
        ):
            return "Tried to build a graph for site '\(expected)' using a BuildContext for '\(actual)'."
        }
    }
}
