// import Constructors
import HTML
import Path
import Primitives

public struct PageTarget: Targetable, MetadataTargetable {
    public let html: @Sendable () -> HTMLDocument
    // public let html: @Sendable (NavigationTree) -> HTMLDocument

    public let output: GenericPath
    public let visibility: Set<BuildEnvironment>
    public let navigation: NavigationSetting

    public let metadata: TargetMetadata

    public init(
        html: @Sendable @escaping () -> HTMLDocument,
        output: GenericPath,
        visibility: Set<BuildEnvironment> = [.local, .test, .public],
        navigation: NavigationSetting = .none,
        metadata: TargetMetadata? = nil
    ) {
        self.html = html
        // self.html = { _ in html() }
        self.output = output
        self.visibility = visibility
        self.navigation = navigation

        if let metadata {
            self.metadata = metadata
        } else {
            self.metadata = visibility.contains(.public) ? .default : .blocked
        }
    }

    public func document() -> HTMLDocument {
        html()
    }
}
