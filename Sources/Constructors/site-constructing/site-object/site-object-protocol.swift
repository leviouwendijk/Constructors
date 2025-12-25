import Foundation
import Version

public protocol SiteObject: Sendable {
    // static var site: Site { get }
    static var site: any SiteResolvable { get }

    static var obj_version: ObjectVersion { get }
    static var version: String { get }
    
    associatedtype Page: TargetIdentifying = _EmptyPages
        where 
            Page.RawValue == String,
            Page.TargetType == PageTarget

    associatedtype Stylesheet: TargetIdentifying = _EmptyStylesheets
        where 
            Stylesheet.RawValue == String,
            Stylesheet.TargetType == StylesheetTarget

    associatedtype Snippet: TargetIdentifying = _EmptySnippets
        where 
            Snippet.RawValue == String,
            Snippet.TargetType == SnippetTargets

    static func navigation() -> NavigationStructure

    static var _pagesType: Any.Type { get }
    static var _stylesheetsType: Any.Type { get }
    static var _snippetsType: Any.Type { get }
}

