public protocol TargetIdentifying: CaseIterable, Hashable, Sendable, RawRepresentable {
    associatedtype TargetType: Targetable

    /// String key to use in dictionaries / filenames.
    var key: String { get }
    func target() -> TargetType
}
