public extension SiteObject {
    static func keyedPages() throws -> [String: PageTarget] {
        if try SiteObjectComponent.pages.check(for: Self.self) {
            return [:]
        }

        var dict: [String: PageTarget] = [:]
        dict.reserveCapacity(Page.allCases.count)

        for e in Page.allCases {
            let key = e.rawValue
            if dict.updateValue(e.target(), forKey: key) != nil {
                throw SiteObjectKeyError.duplicatePageKey(site: Self.self, key: key)
            }
        }

        return dict
    }

    static func keyedStylesheets() throws -> [String: StylesheetTarget] {
        if try SiteObjectComponent.stylesheets.check(for: Self.self) {
            return [:]
        }

        var dict: [String: StylesheetTarget] = [:]
        dict.reserveCapacity(Stylesheet.allCases.count)

        for e in Stylesheet.allCases {
            let key = e.rawValue
            if dict.updateValue(e.target(), forKey: key) != nil {
                throw SiteObjectKeyError.duplicateStylesheetKey(site: Self.self, key: key)
            }
        }

        return dict
    }

    static func keyedSnippets() throws -> [String: SnippetTargets] {
        if try SiteObjectComponent.snippets.check(for: Self.self) {
            return [:]
        }

        var dict: [String: SnippetTargets] = [:]
        dict.reserveCapacity(Snippet.allCases.count)

        for e in Snippet.allCases {
            let key = e.rawValue
            if dict.updateValue(e.target(), forKey: key) != nil {
                throw SiteObjectKeyError.duplicateSnippetKey(site: Self.self, key: key)
            }
        }

        return dict
    }

    // static func keyedPages() -> [String: PageTarget] {
    //     return Page.allCases.reduce(into: [:]) { dictionary, element in
    //         dictionary[element.rawValue] = element.target() 
    //     }
    // }

    // static func keyedStylesheets() -> [String: StylesheetTarget] {
    //     return Stylesheet.allCases.reduce(into: [:]) { dictionary, element in
    //         dictionary[element.rawValue] = element.target() 
    //     }
    // }

    // static func keyedSnippets() -> [String: SnippetTargets] {
    //     return Snippet.allCases.reduce(into: [:]) { dictionary, element in
    //         dictionary[element.rawValue] = element.target() 
    //     }
    // }
}

public extension SiteObject {
    static func arraySnippets() -> [SnippetTargets] {
        return Snippet.allCases.map { $0.target() }
    }

    static func arrayPages() -> [PageTarget] {
        return Page.allCases.map { $0.target() }
    }

    static func arrayStylesheets() -> [StylesheetTarget] {
        return Stylesheet.allCases.map { $0.target() }
    }
}
