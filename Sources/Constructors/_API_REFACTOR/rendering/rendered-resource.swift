import Primitives

/// A semantic resource after rendering has chosen its representation.
///
/// The protocol intentionally says nothing about filesystem locations,
/// filenames, HTTP responses, or concrete generated-resource identity.
///
/// `RenderedDocument` is the first concrete implementation. Other resource
/// kinds can conform once their declaration, resolution, and projection
/// identities actually exist.
public protocol RenderedResource:
    Sendable
{
    associatedtype Identifier:
        StringIdentifier

    associatedtype Representation:
        Sendable

    var identifier:
        Identifier
    {
        get
    }

    var route:
        SiteRoute
    {
        get
    }

    var representation:
        Representation
    {
        get
    }
}
