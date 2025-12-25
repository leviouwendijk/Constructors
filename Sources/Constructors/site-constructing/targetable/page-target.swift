import HTML
import Path
import Primitives

public struct PageTarget: Targetable, MetadataTargetable {
    public let html: @Sendable () -> HTMLDocument

    public let output: StandardPath
    public let visibility: Set<BuildEnvironment>
    public let navigation: NavigationSetting

    public let metadata: TargetMetadata

    public init(
        html: @Sendable @escaping () -> HTMLDocument,
        output: StandardPath,
        visibility: Set<BuildEnvironment> = [.local, .test, .public],
        navigation: NavigationSetting = .none,
        metadata: TargetMetadata? = nil
    ) {
        self.html = html
        self.output = output
        self.visibility = visibility
        self.navigation = navigation
        self.metadata = 
            metadata.exists_or_inits(visibility: visibility)
    }

    public func document() -> HTMLDocument {
        html()
    }
}
