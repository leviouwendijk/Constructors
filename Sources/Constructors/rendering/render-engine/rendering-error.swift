import Foundation

public enum RenderingError: LocalizedError, Sendable {
    case siteNotFound(site: any SiteResolvable)
    case pageNotFound(site: any SiteResolvable, page: String)
    case snippetNotFound(site: any SiteResolvable, id: String)

    case createDirFailed(url: URL, underlying: Error)
    case writeFailed(url: URL, underlying: Error)
    case assetsSyncFailed(underlying: Error)

    public var errorDescription: String? {
        switch self {
        case let .siteNotFound(site):
            return "No site '\(site.rawValue)' is registered."

        case let .pageNotFound(site, page):
            return "No page '\(page)' is registered for site '\(site.rawValue)'."

        case let .snippetNotFound(site, id):
            return "No snippet '\(id)' is registered for site '\(site.rawValue)'."

        case let .createDirFailed(url, _):
            return "Failed to create output directory at \(url.path)."

        case let .writeFailed(url, _):
            return "Failed to write generated output to \(url.path)."

        case .assetsSyncFailed:
            return "Failed to copy public assets to the target distribution."
        }
    }

    public var failureReason: String? {
        switch self {
        case .siteNotFound:
            return "The requested site is not present in the registry."

        case .pageNotFound:
            return "The requested page does not exist in the site’s page registry."

        case .snippetNotFound:
            return "The requested snippet id does not exist in the site’s snippet registry."

        case .createDirFailed:
            return "The filesystem operation to create the directory failed."

        case .writeFailed:
            return "The filesystem operation to write the file failed."

        case .assetsSyncFailed:
            return "An error occurred while mirroring selected files from the public tree."
        }
    }

    public var recoverySuggestion: String? {
        switch self {
        case .siteNotFound:
            return "Register the site in Registry.registrars, then try again."

        case .pageNotFound:
            return "Check the page key produced by the site pages list, or add the page to the site."

        case .snippetNotFound:
            return "Check the snippet key produced by the site snippets list, or add the snippet to the site."

        case .createDirFailed:
            return "Verify permissions and the target path, then try again."

        case .writeFailed:
            return "Ensure the destination is writable and has enough space."

        case .assetsSyncFailed:
            return "Verify the public dist path exists and contains the expected files."
        }
    }

    public var underlyingError: Error? {
        switch self {
        case let .createDirFailed(_, e),
             let .writeFailed(_, e),
             let .assetsSyncFailed(e):
            return e

        case .siteNotFound,
             .pageNotFound,
             .snippetNotFound:
            return nil
        }
    }
}
