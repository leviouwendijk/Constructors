import HTML
import Primitives

public struct DocumentEvaluationOptions: Sendable {
    public let html_attributes: HTMLAttribute
    public let lang: String?
    public let title: String?
    public let style: BundleHTMLDocumentStyle
    public let script: BundleHTMLDocumentScript
    public let referenceOptions: HTMLAssetReferenceOptions

    public init(
        html_attributes: HTMLAttribute = HTMLAttribute(),
        lang: String? = nil,
        title: String? = nil,
        style: BundleHTMLDocumentStyle = .inline(),
        script: BundleHTMLDocumentScript = .inline,
        referenceOptions: HTMLAssetReferenceOptions = .root
    ) {
        self.html_attributes = html_attributes
        self.lang = lang
        self.title = title
        self.style = style
        self.script = script
        self.referenceOptions = referenceOptions
    }

    public static let `default` = Self()

    public func evaluate(
        _ bundle: RenderBundle,
        route: BundleExportRoute
    ) -> EvaluatedBundleExport {
        bundle.export.document.html.evaluate(
            route: route,
            html_attributes: html_attributes,
            lang: lang,
            title: title,
            style: style,
            script: script,
            referenceOptions: referenceOptions
        )
    }
}
