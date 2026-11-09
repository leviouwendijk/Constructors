/// Site-independent capability for components whose authoritative semantic
/// result is a `ComponentOutput`.
///
/// This protocol intentionally says nothing about site page identity,
/// resolution, projection, rendering, serialization, or materialization.
///
/// `ReusableComponent` remains a separate compatibility protocol during
/// consumer migration.
public protocol ComponentOutputProviding:
    Sendable
{
    var output:
        ComponentOutput
    { get }
}
