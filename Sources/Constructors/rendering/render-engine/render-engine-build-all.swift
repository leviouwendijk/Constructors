extension RenderEngine {
    public func buildAll(
        includeSnippets: Bool
    ) throws {
        try context.env.pull_assets(for: context.site)

        let renderedDocs = try buildPages()
        try buildStyles(documents: renderedDocs)

        if includeSnippets {
            try buildSnippets(snippetID: nil)
        }

        try buildMetadataFiles()
    }
}
