import Foundation

public typealias _EmptyPages = _EmptyDefaultInitializer<PageTarget>
public typealias _EmptyStylesheets = _EmptyDefaultInitializer<StylesheetTarget>
public typealias _EmptySnippets = _EmptyDefaultInitializer<SnippetTargets>

public enum _EmptyDefaultInitializer<T: Targetable>: String, TargetIdentifying {
    public typealias TargetType = T

    case none

    public func target() -> T {
        fatalError("No target defined for this site")
    }
}

// public enum _EmptyStylesheets: String, TargetIdentifying {
//     public typealias TargetType = StylesheetTarget

//     case none

//     public func target() -> StylesheetTarget {
//         fatalError("No StylesheetTarget defined for this site")
//     }
// }

// public enum _EmptySnippets: String, TargetIdentifying {
//     public typealias TargetType = SnippetTargets

//     case none

//     public func target() -> SnippetTargets {
//         fatalError("No SnippetTargets defined for this site")
//     }
// }
