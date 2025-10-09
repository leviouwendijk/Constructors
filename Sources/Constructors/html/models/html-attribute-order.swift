import Foundation

public enum HTMLAttributeOrder: Sendable {
    case preserve
    case ranked
    case custom(@Sendable (String, String) -> Bool)
}
