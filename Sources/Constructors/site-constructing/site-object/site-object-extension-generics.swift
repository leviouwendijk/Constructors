public extension SiteObject {
    // // default if not set
    // @available(*, message: "Being replaced by new existential typed enums")
    // static func styles() -> [StylesheetTarget] { [] }

    // // default if not set
    // @available(*, message: "Being replaced by new existential typed enums")
    // static func snippets() -> [String: SnippetTargets] { [:] }

    // fast accessible API from self
    static func navigation() -> NavigationInterface { 
        return NavigationInterface.build(
            // from: pages()
            from: arrayPages()
        ) { target in
            let visible = target.visibility.contains(.public)
            guard visible else { return false }

            return target.navigation != .none
        }
    }

    static var version: String { 
        obj_version.string(prefixStyle: .none, prefixSpace: false) 
    }
}

public extension SiteObject {
    // helpers that exposes types for equatable comparison
    static var _pagesType: Any.Type { Page.self }
    static var _stylesheetsType: Any.Type { Stylesheet.self }
    static var _snippetsType: Any.Type { Snippet.self }

    func _componentType(for component: SiteObjectComponent) -> Any.Type {
        switch component {
        case .pages:
            return Self._pagesType

        case .stylesheets:
            return Self._stylesheetsType

        case .snippets:
            return Self._snippetsType
        }
    }
}
