import HTML
import JS

public extension HTML {
    static func script(
        _ script: JSScript,
        _ extra: HTMLAttribute = HTMLAttribute()
    ) -> any HTMLNode {
        switch script {
        case .inline(let source, let attributes):
            var attrs = extra

            if let type = attributes.kind.html_type_attribute {
                attrs.merge(["type": type])
            }

            if let integrity = attributes.integrity {
                attrs.merge(["integrity": integrity])
            }

            if let crossorigin = attributes.crossorigin {
                attrs.merge(["crossorigin": crossorigin])
            }

            if let nonce = attributes.nonce {
                attrs.merge(["nonce": nonce])
            }

            if attributes.defer_loading {
                attrs.merge(.bool("defer", true))
            }

            if attributes.async_loading {
                attrs.merge(.bool("async", true))
            }

            return HTML.el("script", attrs) {
                HTML.raw(source.render())
            }

        case .external(let external, let attributes):
            var attrs = extra
            attrs.merge(["src": external.render()])

            if let type = attributes.kind.html_type_attribute {
                attrs.merge(["type": type])
            }

            if let integrity = attributes.integrity {
                attrs.merge(["integrity": integrity])
            }

            if let crossorigin = attributes.crossorigin {
                attrs.merge(["crossorigin": crossorigin])
            }

            if let nonce = attributes.nonce {
                attrs.merge(["nonce": nonce])
            }

            if attributes.defer_loading {
                attrs.merge(.bool("defer", true))
            }

            if attributes.async_loading {
                attrs.merge(.bool("async", true))
            }

            return HTML.el("script", attrs)
        }
    }
}

public extension Array where Element == JSScript {
    func html_nodes() -> HTMLFragment {
        self.map { HTML.script($0) }
    }
}
