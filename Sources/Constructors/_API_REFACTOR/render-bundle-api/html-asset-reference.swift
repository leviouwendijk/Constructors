import Path
import PathWeb
import ProtocolComponents


public struct HTMLAssetReference: Sendable, Equatable,ExpressibleByStringLiteral {
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
