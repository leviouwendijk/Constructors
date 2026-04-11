import CSS
import Path

public struct StylesheetTarget: Targetable {
    public let name: String
    public let sheet: CSSStyleSheet
    public let output: StandardPath
    public let pruneUnusedSelectors: Bool
    public let indentStep: Int

    public init(
        name: String,
        sheet: CSSStyleSheet,
        output: StandardPath,
        pruneUnusedSelectors: Bool = true,
        indentStep: Int = 4
    ) {
        self.name = name
        self.sheet = sheet
        self.output = output
        self.pruneUnusedSelectors = pruneUnusedSelectors
        self.indentStep = indentStep
    }
}

// public extension StylesheetTarget {
//     init(
//         name: String,
//         artifact: RenderArtifact,
//         output: StandardPath,
//         pruneUnusedSelectors: Bool = true,
//         indentStep: Int = 4
//     ) {
//         self.init(
//             name: name,
//             sheet: CSSBundle(artifact.stylesheets).mergedSheet,
//             output: output,
//             pruneUnusedSelectors: pruneUnusedSelectors,
//             indentStep: indentStep
//         )
//     }

//     init(
//         name: String,
//         artifacts: [RenderArtifact],
//         output: StandardPath,
//         pruneUnusedSelectors: Bool = true,
//         indentStep: Int = 4
//     ) {
//         self.init(
//             name: name,
//             sheet: CSSBundle(
//                 artifacts.flatMap(\.stylesheets)
//             ).mergedSheet,
//             output: output,
//             pruneUnusedSelectors: pruneUnusedSelectors,
//             indentStep: indentStep
//         )
//     }
// }
