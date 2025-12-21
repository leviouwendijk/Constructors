import Foundation

public enum SiteResolvingError: Error, LocalizedError {
    case noSiteObjectConfigured(any SiteResolvable)

    public var errorDescription: String? {
        switch self {
        case .noSiteObjectConfigured(let site):
            return "No site_object has been configured yet for \(site.rawValue)"
        }
    }
}
