import HTML
import JS

public extension HTML {
    static func scriptCall(_ fn: String, args: [JSValue], type: String? = "module") -> any HTMLNode {
        HTML.scriptInline(JS.call(fn, args), type: type)
    }

    /// Emit `<script type="application/json" id="...">…</script>` for props
    static func jsonProps(id: String, _ value: JSValue) -> any HTMLNode {
        HTML.el("script", ["type":"application/json","id": id]) {
            HTML.raw(value.render()) // contents are JSON, not escaped text
        }
    }
}
