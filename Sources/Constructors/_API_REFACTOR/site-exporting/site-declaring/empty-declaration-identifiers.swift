public struct _EmptyDeclarationIdentifiers: DeclarationIdentifier {
    public let rawValue: String

    public init?(
        rawValue: String
    ) {
        self.rawValue = rawValue
    }
}
