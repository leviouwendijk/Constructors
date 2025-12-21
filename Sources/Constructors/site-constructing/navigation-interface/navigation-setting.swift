public enum NavigationSetting: Sendable, Equatable {
    /// Infer nav hierarchy from the page’s output path.
    /// Example: ["problemen", "uitvallen.html"] → ["Problemen", "Uitvallen"]
    case auto(NavigationRenderOptions = .init())

    /// Explicit hierarchical path; used as-is, no slug-prettifying etc.
    /// Example: .custom(["Gedragsproblemen", "Uitvallen aan de lijn"])
    case custom([String])

    /// Do not include this page in the navigation tree.
    case none
}

public struct NavigationRenderOptions: Sendable, Equatable {
    public var capitalization: Capitalization
    public var space_chars: [String]
    
    public init(
        capitalization: Capitalization = .per_word,
        space_chars: [String] = ["-", "_"]
    ) {
        self.capitalization = capitalization
        self.space_chars = space_chars
    }

    public enum Capitalization: Sendable {
        case per_word
        case first_word
    }
}
