import Foundation
import Path
import Primitives

public enum SiteRenderingPolicyError:
    Error,
    Sendable,
    Equatable
{
    case absoluteReferenceRequiresBaseURL
}

/// Site-level policy for semantic-to-rendered representation choices.
///
/// This policy does not decide semantic existence and does not describe
/// filesystem output. Projection has already established existence before a
/// reference reaches this layer.
public struct SiteRenderingPolicy:
    Sendable,
    Equatable
{
    public let absoluteBaseURL:
        URL?

    public init(
        absoluteBaseURL:
            URL? = nil
    ) {
        self.absoluteBaseURL =
            absoluteBaseURL
    }

    func href<
        Identifier:
            StringIdentifier
    >(
        for reference:
            ProjectedReference<Identifier>
    ) throws -> String {
        switch reference.style {
        case .automatic:
            return
                reference
                    .destinationRoute
                    .href

        case .local(
            let relativity
        ):
            return
                localHref(
                    for:
                        reference
                            .destinationRoute,
                    relativity:
                        relativity
                )

        case .absolute:
            guard
                let absoluteBaseURL
            else {
                throw
                    SiteRenderingPolicyError
                        .absoluteReferenceRequiresBaseURL
            }

            return
                absoluteHref(
                    for:
                        reference
                            .destinationRoute,
                    baseURL:
                        absoluteBaseURL
                )
        }
    }

    private func localHref(
        for route:
            SiteRoute,
        relativity:
            PathRelativity
    ) -> String {
        switch relativity {
        case .root:
            return
                route.href

        case .relative:
            guard
                route != .root
            else {
                return "./"
            }

            return
                String(
                    route
                        .href
                        .dropFirst()
                )
        }
    }

    private func absoluteHref(
        for route:
            SiteRoute,
        baseURL:
            URL
    ) -> String {
        var base =
            baseURL
                .absoluteString

        while
            base.hasSuffix(
                "/"
            )
        {
            base.removeLast()
        }

        return
            base
            + route.href
    }
}
