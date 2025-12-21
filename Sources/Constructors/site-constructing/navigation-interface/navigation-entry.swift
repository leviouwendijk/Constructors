public struct NavigationEntry: Sendable {
    public let segments: [String]  // e.g. ["Problemen", "Uitvallen"]
    public let path: String        // href, like "/problemen/uitvallen.html"
}
