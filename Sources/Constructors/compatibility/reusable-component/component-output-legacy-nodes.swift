import CSS
import JS

public extension ComponentOutput {
    /// Resolve the complete semantic dependency collection before lowering
    /// into the legacy representation.
    ///
    /// Compose component outputs before calling this method. Resolving
    /// individual children would lose the ability to detect conflicts
    /// between contributions from different components.
    ///
    /// Identity is retained through CSS and JS resolution and deliberately
    /// discarded only when projecting into ReusableComponentNodes.
    func legacyNodes() throws -> ReusableComponentNodes {
        let resolvedStyles = try dependencies.styles.resolve()
        let resolvedScripts = try dependencies.scripts.resolve()

        return ReusableComponentNodes(
            head: content.head,
            body: content.body,
            stylesheets: resolvedStyles.contributions.map(\.content.sheet),
            scripts: resolvedScripts.contributions.map(\.script)
        )
    }
}
