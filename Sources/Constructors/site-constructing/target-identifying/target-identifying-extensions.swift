extension TargetIdentifying {
    /// Default: enumCaseName with `_` replaced by `-`.
    public var key: String {
        String(describing: self)
        .replacingOccurrences(of: "_", with: "-")
    }

    // relative, Page-scoped API
    public static func refer(to id: Self, asRootPath: Bool = true) -> String {
        id.target().output.rendered(asRootPath: asRootPath)
    }

    public func reference(asRootPath: Bool = true) -> String {
        Self.refer(to: self, asRootPath: asRootPath)
    }
}
