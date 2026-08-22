import DSL
import FileTypes
import Path

public struct StaticStylesheetPackagingPolicy:
    Sendable,
    Equatable
{
    public let output:
        StandardPath

    public let selection:
        ScopeSelection

    public init(
        output:
            StandardPath =
                StandardPath(
                    [
                        "assets",
                        "css",
                        "site",
                    ],
                    filetype:
                        .text(
                            .css
                        )
                ),
        selection:
            ScopeSelection =
                .all
    ) {
        self.output =
            output

        self.selection =
            selection
    }
}

public enum StaticJavaScriptPackagingPolicy:
    Sendable,
    Equatable
{
    /// Preserve every resolved JavaScript contribution as its existing
    /// structural script value.
    ///
    /// Inline/external identity and script attributes remain intact.
    /// A later materialization policy may introduce generated-file packaging
    /// only when its semantic constraints are explicit.
    case preserve
}

public struct StaticDependencyPackagingPolicy:
    Sendable,
    Equatable
{
    public let styles:
        StaticStylesheetPackagingPolicy

    public let scripts:
        StaticJavaScriptPackagingPolicy

    public init(
        styles:
            StaticStylesheetPackagingPolicy =
                .init(),
        scripts:
            StaticJavaScriptPackagingPolicy =
                .preserve
    ) {
        self.styles =
            styles

        self.scripts =
            scripts
    }
}
