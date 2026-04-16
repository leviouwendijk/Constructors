public struct _EmptyDeclarationIdentifiers: DeclarationIdentifier {
    public static let allCases: [_EmptyDeclarationIdentifiers] = []

    public let rawValue: String

    public init?(
        rawValue: String
    ) {
        self.rawValue = rawValue
    }
}
