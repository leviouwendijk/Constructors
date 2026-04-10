import HTML
import JS

public struct ScriptPlacementResult: Sendable {
    public let head: HTMLFragment
    public let body: HTMLFragment

    public init(
        head: HTMLFragment = [],
        body: HTMLFragment = []
    ) {
        self.head = head
        self.body = body
    }
}

public func place_scripts(
    _ scripts: [JSScript]
) -> ScriptPlacementResult {
    return ScriptPlacementResult(
        head: [],
        body: scripts.html_nodes()
    )
}
