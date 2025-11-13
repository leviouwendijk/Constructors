import Foundation
import plate

// public struct CSSStyleSheet: Sendable, Equatable {
//     public var rules: [CSSRule]

//     public init(rules: [CSSRule]) {
//         self.rules = rules
//     }

//     public func render(indentation: Int = 4) -> String {
//         var out = ""
//         for rule in rules {
//             out += "\(rule.selector) {\n"
//             for decl in rule.declarations {
//                 out += "\(decl.property): \(decl.value);".indent(indentation)
//                 out += "\n"
//             }
//             out += "}\n\n"
//         }
//         return out
//     }
// }


public struct CSSStyleSheet: Sendable, Equatable {
    public var rules: [CSSRule]
    public var media: [CSSMedia]

    public init(
        rules: [CSSRule],
        media: [CSSMedia] = []
    ) {
        self.rules = rules
        self.media = media
    }

    public func render(indentation: Int = 4) -> String {
        var out = ""

        // top-level rules
        for rule in rules {
            out += renderRule(rule, indentation: indentation, times: 0)
        }

        // media blocks
        for m in media {
            out += renderMedia(m, indentation: indentation)
        }

        return out
    }

    /// Render a rule with an indent *level* (times).
    private func renderRule(
        _ rule: CSSRule,
        indentation: Int,
        times: Int
    ) -> String {
        var out = ""

        // selector line
        let selectorLine = "\(rule.selector) {"
        if times > 0 {
            out += selectorLine.indent(indentation, times: times)
        } else {
            out += selectorLine
        }
        out += "\n"

        // declarations
        let declTimes = times + 1
        for decl in rule.declarations {
            out += "\(decl.property): \(decl.value);".indent(indentation, times: declTimes)
            out += "\n"
        }

        // closing brace
        let closing = "}"
        if times > 0 {
            out += closing.indent(indentation, times: times)
        } else {
            out += closing
        }
        out += "\n\n"

        return out
    }

    private func renderMedia(
        _ media: CSSMedia,
        indentation: Int
    ) -> String {
        var out = ""

        // @media line (no indent, like top-level rules)
        out += "@media \(media.query) {\n"

        // Inner rules, one indent level inside the media block
        for rule in media.rules {
            out += renderRule(rule, indentation: indentation, times: 1)
        }

        out += "}\n\n"
        return out
    }
}
