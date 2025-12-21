import CSS
import Path

public struct StylesheetTarget: Targetable {
    /// Friendly identifier, e.g. "dynamic", "critical", etc.
    public let name: String

    /// The stylesheet to render.
    public let sheet: CSSStyleSheet

    /// Where to write it relative to the site root
    /// e.g. ["assets", "css", "dynamic-minified.css"]
    public let output: GenericPath

    /// Whether to drop unused selectors based on referenced classes/ids
    /// across all rendered documents.
    public let pruneUnusedSelectors: Bool

    /// Optional override for indent/minification; default is "minified-ish".
    public let indentStep: Int

    public init(
        name: String,
        sheet: CSSStyleSheet,
        output: GenericPath,
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
