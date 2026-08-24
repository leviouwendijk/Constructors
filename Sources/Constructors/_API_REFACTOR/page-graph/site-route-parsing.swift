/// Failures while converting an external URL path component into logical
/// `SiteRoute` identity.
///
/// This parser is deliberately not a general URL parser. Callers must supply
/// only the path component that identifies a site route.
public enum SiteRouteParsingError:
    Error,
    Sendable,
    Equatable
{
    case pathMustStartWithSlash(
        String
    )

    case queryOrFragmentNotAllowed(
        String
    )

    case emptySegment(
        String
    )

    case dotSegment(
        path:
            String,
        segment:
            String
    )
}

public extension SiteRoute {
    /// Parse one external URL path component into logical route identity.
    ///
    /// Accepted forms are canonicalized into the same structural route:
    ///
    ///     /
    ///     /contact
    ///     /contact/
    ///     /account/agreement
    ///     /account/agreement/
    ///
    /// `href` remains the canonical serializer and emits a trailing slash for
    /// every non-root route.
    ///
    /// Query strings and fragments are rejected because they are not part of
    /// site-route identity. Empty interior segments and dot-navigation segments
    /// are rejected rather than normalized.
    init(
        parsingPath path:
            String
    ) throws {
        guard
            path
                .first
                == "/"
        else {
            throw
                SiteRouteParsingError
                    .pathMustStartWithSlash(
                        path
                    )
        }

        guard
            !path
                .contains(
                    "?"
                )
            && !path
                .contains(
                    "#"
                )
        else {
            throw
                SiteRouteParsingError
                    .queryOrFragmentNotAllowed(
                        path
                    )
        }

        guard
            path
                != "/"
        else {
            self =
                .root

            return
        }

        let body =
            path
                .dropFirst()

        var pieces =
            body
                .split(
                    separator:
                        "/",
                    omittingEmptySubsequences:
                        false
                )

        if
            pieces
                .last?
                .isEmpty
                == true
        {
            pieces
                .removeLast()
        }

        guard
            !pieces
                .contains(
                    where:
                        \.isEmpty
                )
        else {
            throw
                SiteRouteParsingError
                    .emptySegment(
                        path
                    )
        }

        for piece in pieces {
            if
                piece
                    == "."
                || piece
                    == ".."
            {
                throw
                    SiteRouteParsingError
                        .dotSegment(
                            path:
                                path,
                            segment:
                                String(
                                    piece
                                )
                        )
            }
        }

        self.init(
            resolvedSegments:
                pieces
                    .map { piece in
                        Segment(
                            String(
                                piece
                            )
                        )
                    }
        )
    }
}
