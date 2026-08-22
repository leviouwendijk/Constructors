import Foundation

public enum SiteReferenceResolutionError:
    Error,
    LocalizedError,
    Sendable,
    Equatable
{
    case sourceNotFound(
        String
    )

    case destinationNotFound(
        String
    )

    public var errorDescription:
        String?
    {
        switch self {
        case .sourceNotFound(
            let identifier
        ):
            return
                "Reference source '\(identifier)' does not exist in the resolved page graph."

        case .destinationNotFound(
            let identifier
        ):
            return
                "Reference destination '\(identifier)' does not exist in the resolved page graph."
        }
    }
}
