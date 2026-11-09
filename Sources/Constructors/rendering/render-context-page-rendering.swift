public enum RenderContextRenderingError:
    Error,
    Sendable,
    Equatable
{
    case pageNotProjected(
        String
    )
}

public extension RenderContext {
    /// Render one page from this context using caller-owned typed state.
    ///
    /// This is the request/state-friendly boundary for future SSR use. The
    /// caller is responsible for obtaining domain state before entering this
    /// operation; Constructors neither stores nor interprets that state.
    ///
    /// The renderer is not a semantic-reference discovery surface. Site
    /// references participating in graph validity must already have been
    /// declared, resolved, and projected before terminal page rendering.
    func render<
        State:
            Sendable
    >(
        page identifier:
            Page.PageIdentifier,
        state:
            State,
        using renderer:
            (
                PageProjection<Page>,
                State,
                RenderContext<Page>
            ) throws -> PageRenderOutput
    ) throws -> RenderedDocument<Page> {
        guard
            let projectedPage =
                projection[
                    identifier
                ]
        else {
            throw
                RenderContextRenderingError
                    .pageNotProjected(
                        identifier
                            .rawValue
                    )
        }

        let output =
            try renderer(
                projectedPage,
                state,
                self
            )

        return
            try renderedDocument(
                projectedPage:
                    projectedPage,
                output:
                    output
            )
    }

    /// Render one page when no additional caller state is required.
    func render(
        page identifier:
            Page.PageIdentifier,
        using renderer:
            (
                PageProjection<Page>,
                RenderContext<Page>
            ) throws -> PageRenderOutput
    ) throws -> RenderedDocument<Page> {
        guard
            let projectedPage =
                projection[
                    identifier
                ]
        else {
            throw
                RenderContextRenderingError
                    .pageNotProjected(
                        identifier
                            .rawValue
                    )
        }

        let output =
            try renderer(
                projectedPage,
                self
            )

        return
            try renderedDocument(
                projectedPage:
                    projectedPage,
                output:
                    output
            )
    }

    /// Render every page that exists in this projection using one caller-owned
    /// state value.
    ///
    /// A site library may make that state a richer structure containing
    /// per-page values. Constructors only forwards it unchanged.
    func renderSite<
        State:
            Sendable
    >(
        state:
            State,
        using renderer:
            (
                PageProjection<Page>,
                State,
                RenderContext<Page>
            ) throws -> PageRenderOutput
    ) throws -> SiteRenderResult<Page> {
        let documents =
            try projection
                .pages
                .map { projectedPage in
                    let output =
                        try renderer(
                            projectedPage,
                            state,
                            self
                        )

                    return
                        try renderedDocument(
                            projectedPage:
                                projectedPage,
                            output:
                                output
                        )
                }

        return
            try SiteRenderResult(
                projection:
                    projection,
                documents:
                    documents
            )
    }

    /// Render every page that exists in this projection without additional
    /// caller state.
    func renderSite(
        using renderer:
            (
                PageProjection<Page>,
                RenderContext<Page>
            ) throws -> PageRenderOutput
    ) throws -> SiteRenderResult<Page> {
        let documents =
            try projection
                .pages
                .map { projectedPage in
                    let output =
                        try renderer(
                            projectedPage,
                            self
                        )

                    return
                        try renderedDocument(
                            projectedPage:
                                projectedPage,
                            output:
                                output
                        )
                }

        return
            try SiteRenderResult(
                projection:
                    projection,
                documents:
                    documents
            )
    }

    private func renderedDocument(
        projectedPage:
            PageProjection<Page>,
        output:
            PageRenderOutput
    ) throws -> RenderedDocument<Page> {
        let dependencies =
            RenderDependencies(
                styles:
                    try output
                        .styles
                        .resolve(),
                scripts:
                    try output
                        .scripts
                        .resolve()
            )

        return
            RenderedDocument(
                projectedPage:
                    projectedPage,
                document:
                    output.document,
                dependencies:
                    dependencies
            )
    }
}
