import Foundation

public enum PageGraphError:
    Error,
    LocalizedError,
    Sendable,
    Equatable
{
    case duplicateIdentifier(
        String
    )

    case duplicateRoute(
        SiteRoute
    )

    case slashBearingSlug(
        String
    )

    public var errorDescription:
        String?
    {
        switch self {
        case .duplicateIdentifier(
            let identifier
        ):
            return
                "Duplicate page identifier '\(identifier)'."

        case .duplicateRoute(
            let route
        ):
            return
                "Duplicate page route '\(route.href)'."

        case .slashBearingSlug(
            let slug
        ):
            return
                "Page slug '\(slug)' contains '/'. Use parent pages for route nesting."
        }
    }
}
