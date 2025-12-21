import Foundation
import Methods

public enum SiteObjectComponent {
    case pages
    case stylesheets
    case snippets

    public func empty_type() -> Any.Type {
        switch self {
        case .pages:
            return _EmptyPages.self

        case .stylesheets:
            return _EmptyStylesheets.self

        case .snippets:
            return _EmptySnippets.self
        }
    }

    public func site_object_component_type(
        for site_object: any SiteObject.Type
    ) -> Any.Type {
        switch self {
        case .pages:
            return site_object._pagesType

        case .stylesheets:
            return site_object._stylesheetsType

        case .snippets:
            return site_object._snippetsType
        }
    }

    public func check(
        for site_object: any SiteObject.Type,
        verbose: Bool = false
    ) throws -> Bool {
        let obj_type = site_object_component_type(for: site_object)
        return anysametype(obj_type, empty_type(), verbose: verbose)
    }

    public static func check(
        for site_object: any SiteObject.Type,
        target: SiteObjectComponent,
        verbose: Bool = false
    ) throws -> Bool {
        return try target.check(for: site_object, verbose: verbose)
    }
}
