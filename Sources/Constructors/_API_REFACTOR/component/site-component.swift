import Primitives

/// One component occurrence bound to the page that contains it.
///
/// Site-independent authoring remains in `ComponentOutput`. This boundary is
/// entered only when page/site composition knows source-page identity.
///
/// Converting destination-oriented `SiteReference` values into
/// `SiteReferenceDeclaration` happens here, before site Resolution.
public struct SiteComponent<
    Identifier:
        StringIdentifier
>:
    Sendable
{
    public let source:
        Identifier

    public let content:
        ComponentContent

    public let contribution:
        ComponentContribution<
            Identifier
        >

    public init(
        source:
            Identifier,
        output:
            ComponentOutput,
        references:
            [
                SiteReference<
                    Identifier
                >
            ] = []
    ) {
        self.source =
            source

        self.content =
            output
                .content

        self.contribution =
            ComponentContribution(
                references:
                    references,
                dependencies:
                    output
                        .dependencies
            )
    }

    public init(
        source:
            Identifier,
        content:
            ComponentContent =
                .empty,
        contribution:
            ComponentContribution<
                Identifier
            >
    ) {
        self.source =
            source

        self.content =
            content

        self.contribution =
            contribution
    }

    public var referenceDeclarations:
        [
            SiteReferenceDeclaration<
                Identifier
            >
        ]
    {
        contribution
            .references
            .map { reference in
                SiteReferenceDeclaration(
                    source:
                        source,
                    reference:
                        reference
                )
            }
    }
}
