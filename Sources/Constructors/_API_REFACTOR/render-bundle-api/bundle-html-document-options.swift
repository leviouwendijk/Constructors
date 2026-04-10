import CSS
import JS

public struct BundleHTMLAssetOptions: Sendable, Equatable {
    public let linked: [HTMLAssetReference]

    public init(
        linked: [HTMLAssetReference] = []
    ) {
        self.linked = linked
    }

    public static let empty = Self()

    public func appending(
        _ reference: HTMLAssetReference
    ) -> Self {
        Self(
            linked: linked + [reference]
        )
    }

    public func appending(
        _ references: [HTMLAssetReference]
    ) -> Self {
        Self(
            linked: linked + references
        )
    }
}

public struct BundleHTMLCSSRenderOptions: Sendable, Equatable {
    public let unreferenced: CSSUnreferenced
    public let indentStep: Int
    public let ensureTrailingNewline: Bool

    public init(
        unreferenced: CSSUnreferenced = .commented,
        indentStep: Int = 4,
        ensureTrailingNewline: Bool = true
    ) {
        self.unreferenced = unreferenced
        self.indentStep = indentStep
        self.ensureTrailingNewline = ensureTrailingNewline
    }

    public static let `default` = Self()
}

public struct BundleHTMLStyleOptions: Sendable, Equatable {
    public let assets: BundleHTMLAssetOptions
    public let css: BundleHTMLCSSRenderOptions

    public init(
        assets: BundleHTMLAssetOptions = .empty,
        css: BundleHTMLCSSRenderOptions = .default
    ) {
        self.assets = assets
        self.css = css
    }

    public static let `default` = Self()
}

public struct BundleHTMLScriptOptions: Sendable, Equatable {
    public let attributes: JSScriptAttributes
    public let ensureTrailingNewline: Bool

    public init(
        attributes: JSScriptAttributes = .default,
        ensureTrailingNewline: Bool = true
    ) {
        self.attributes = attributes
        self.ensureTrailingNewline = ensureTrailingNewline
    }

    public static let `default` = Self()
}
