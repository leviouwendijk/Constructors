import HTML
import CSS

public extension HTML {
    // Base: single sheet, with optional options (default = plain render)
    static func style(
        _ sheet: CSSStyleSheet,
        options: CSSRenderOptions = CSSRenderOptions()
    ) -> any HTMLNode {
        HTML.el("style") {
            HTML.raw(sheet.render(options: options))
        }
    }

    // Array of sheets
    static func style(
        _ sheets: [CSSStyleSheet],
        options: CSSRenderOptions = CSSRenderOptions()
    ) -> any HTMLNode {
        style(CSSStyleSheet.merged(sheets), options: options)
    }

    // Varargs sheets
    static func style(
        _ sheets: CSSStyleSheet...,
        options: CSSRenderOptions = CSSRenderOptions()
    ) -> any HTMLNode {
        style(CSSStyleSheet.merged(sheets), options: options)
    }

    // Rules + media → sheet
    static func style(
        rules: [CSSRule],
        media: [CSSMedia] = [],
        keyframes: [CSSKeyframes] = [],
        options: CSSRenderOptions = CSSRenderOptions()
    ) -> any HTMLNode {
        let sheet = CSSStyleSheet(
            rules: rules,
            media: media,
            keyframes: keyframes
        )
        return style(sheet, options: options)
    }

    static func style(
        @CSSBuilder _ css: () -> [CSSBlock],
        options: CSSRenderOptions = CSSRenderOptions()
    ) -> any HTMLNode {
        var rules: [CSSRule] = []
        var media: [CSSMedia] = []
        var keyframes: [CSSKeyframes] = []

        for block in css() {
            switch block {
            case .rule(let r):
                rules.append(r)
            case .media(let m):
                media.append(m)
            case .keyframes(let k):
                keyframes.append(k)
            }
        }

        return style(
            rules: rules,
            media: media,
            keyframes: keyframes,
            options: options
        )
    }
}
