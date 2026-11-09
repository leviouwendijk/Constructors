import Primitives

/// One authoring-time semantic relationship as it exists in a site
/// declaration.
///
/// `SiteReference` owns the destination and requested rendering style.
/// The containing composition/site declaration owns where that relationship
/// originates, so source identity is retained separately here rather than
/// being embedded into `SiteReference` itself.
public struct SiteReferenceDeclaration<
    Identifier:
        StringIdentifier
>:
    Sendable
{
    public let source:
        Identifier

    public let reference:
        SiteReference<Identifier>

    public init(
        source:
            Identifier,
        reference:
            SiteReference<Identifier>
    ) {
        self.source =
            source

        self.reference =
            reference
    }
}
