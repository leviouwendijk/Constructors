import Path
import PathWeb
import ProtocolComponents

public struct HTMLAssetReference: Sendable, Equatable, ExpressibleByStringLiteral {
    public enum Value: Sendable, Equatable {
        case web(WebReference)
        case raw(String)
    }

    public let value: Value
    public let options: HTMLAssetReferenceOptions?

    public init(
        value: Value,
        options: HTMLAssetReferenceOptions? = nil
    ) {
        self.value = value
        self.options = options
    }

    public init(
        _ path: StandardPath,
        options: HTMLAssetReferenceOptions? = nil
    ) {
        self.value = .web(
            .local(path)
        )
        self.options = options
    }

    public init(
        _ web: WebReference,
        options: HTMLAssetReferenceOptions? = nil
    ) {
        self.value = .web(web)
        self.options = options
    }

    public init(
        _ raw: String,
        options: HTMLAssetReferenceOptions? = nil
    ) {
        self.value = .raw(raw)
        self.options = options
    }

    public init(
        stringLiteral value: String
    ) {
        self.value = .raw(value)
        self.options = nil
    }

    public static func local(
        _ path: StandardPath,
        options: HTMLAssetReferenceOptions? = nil
    ) -> Self {
        Self(
            path,
            options: options
        )
    }

    public static func absolute(
        origin: WebOrigin,
        path: StandardPath = StandardPath(),
        query: [WebQueryItem] = [],
        fragment: String? = nil,
        options: HTMLAssetReferenceOptions? = nil
    ) -> Self {
        Self(
            .absolute(
                origin: origin,
                path: path,
                query: query,
                fragment: fragment
            ),
            options: options
        )
    }

    public static func versioned(
        _ path: StandardPath,
        version: String,
        fragment: String? = nil,
        options: HTMLAssetReferenceOptions? = nil
    ) -> Self {
        Self(
            .versioned(
                path,
                version: version,
                fragment: fragment
            ),
            options: options
        )
    }

    public static func raw(
        _ value: String,
        options: HTMLAssetReferenceOptions? = nil
    ) -> Self {
        Self(
            value,
            options: options
        )
    }

    public func withOptions(
        _ options: HTMLAssetReferenceOptions?
    ) -> Self {
        Self(
            value: value,
            options: options
        )
    }
}

public struct HTMLAssetReferenceOptions: Sendable, Equatable {
    public let relativity: PathRelativity

    public init(
        relativity: PathRelativity = .root
    ) {
        self.relativity = relativity
    }

    public static let root = Self(
        relativity: .root
    )

    public static let relative = Self(
        relativity: .relative
    )
}

public extension SiteObject {
    static func asset_reference(
        path: StandardPath,
        style: SiteReferenceStyle = .automatic
    ) -> HTMLAssetReference {
        resolve_asset_reference(
            path: path,
            destinationSite: Self.site,
            style: style
        )
    }

    static func asset_reference(
        path: StandardPath,
        on destinationSite: any SiteResolvable,
        style: SiteReferenceStyle = .automatic
    ) -> HTMLAssetReference {
        resolve_asset_reference(
            path: path,
            destinationSite: destinationSite,
            style: style
        )
    }

    static func asset_reference<Destination: SiteObject>(
        path: StandardPath,
        on destination: Destination.Type,
        style: SiteReferenceStyle = .automatic
    ) -> HTMLAssetReference {
        asset_reference(
            path: path,
            on: destination.site,
            style: style
        )
    }

    static func asset_reference<T: TargetIdentifying>(
        to target: T,
        on destinationSite: any SiteResolvable,
        style: SiteReferenceStyle = .automatic
    ) -> HTMLAssetReference {
        resolve_asset_reference(
            path: target.target().output,
            destinationSite: destinationSite,
            style: style
        )
    }

    static func asset_reference<Destination: SiteObject, T: TargetIdentifying>(
        to target: T,
        on destination: Destination.Type,
        style: SiteReferenceStyle = .automatic
    ) -> HTMLAssetReference {
        asset_reference(
            to: target,
            on: destination.site,
            style: style
        )
    }

    static func asset_reference(
        page: Page,
        style: SiteReferenceStyle = .automatic
    ) -> HTMLAssetReference {
        resolve_asset_reference(
            path: page.target().output,
            destinationSite: Self.site,
            style: style
        )
    }

    static func asset_reference(
        stylesheet: Stylesheet,
        style: SiteReferenceStyle = .automatic
    ) -> HTMLAssetReference {
        resolve_asset_reference(
            path: stylesheet.target().output,
            destinationSite: Self.site,
            style: style
        )
    }

    static func asset_reference(
        snippet: Snippet,
        style: SiteReferenceStyle = .automatic
    ) -> HTMLAssetReference {
        resolve_asset_reference(
            path: snippet.target().output,
            destinationSite: Self.site,
            style: style
        )
    }
}

private extension SiteObject {
    static func resolve_asset_reference(
        path: StandardPath,
        destinationSite: any SiteResolvable,
        style: SiteReferenceStyle
    ) -> HTMLAssetReference {
        resolve_site_asset_reference(
            sourceSite: Self.site,
            destinationSite: destinationSite,
            path: path,
            style: style
        )
    }
}

// import Path
// import PathWeb

// public enum HTMLAssetReference: Sendable, Equatable, ExpressibleByStringLiteral {
//     case path(StandardPath)
//     case web(WebReference)
//     case raw(String)

//     public init(
//         _ path: StandardPath
//     ) {
//         self = .path(path)
//     }

//     public init(
//         _ web: WebReference
//     ) {
//         self = .web(web)
//     }

//     public init(
//         _ raw: String
//     ) {
//         self = .raw(raw)
//     }

//     public init(
//         stringLiteral value: String
//     ) {
//         self = .raw(value)
//     }
// }

// public struct HTMLAssetReferenceOptions: Sendable, Equatable {
//     public let relativity: PathRelativity

//     public init(
//         relativity: PathRelativity = .root
//     ) {
//         self.relativity = relativity
//     }

//     public static let root = Self(
//         relativity: .root
//     )

//     public static let relative = Self(
//         relativity: .relative
//     )
// }
