import Path
import PathWeb
import ProtocolComponents

public extension BundleHTMLDocumentStyle {
    @available(
        *,
        deprecated,
        message: """
        Prefer BundleHTMLDocumentStyle.linked([Site.stylesheet_key(...)], style: ...)
        so the destination site identity is carried by the typed stylesheet key.
        """
    )
    static func linked<Site: SiteObject>(
        site: Site.Type,
        stylesheets: [Site.Stylesheet],
        style referenceStyle: SiteReferenceStyle = .automatic
    ) -> Self {
        .linked(
            stylesheets.map {
                site.asset_reference(
                    stylesheet: $0,
                    style: referenceStyle
                )
            }
        )
    }

    @available(
        *,
        deprecated,
        message: """
        Prefer BundleHTMLDocumentStyle.linked(from: Source.self, [Destination.stylesheet_key(...)], style: ...)
        so the destination site identity is carried by the typed stylesheet key.
        """
    )
    static func linked<Source: SiteObject, Destination: SiteObject>(
        from source: Source.Type,
        site destination: Destination.Type,
        stylesheets: [Destination.Stylesheet],
        style referenceStyle: SiteReferenceStyle = .automatic
    ) -> Self {
        .linked(
            stylesheets.map {
                source.asset_reference(
                    to: $0,
                    on: destination,
                    style: referenceStyle
                )
            }
        )
    }
}

// public extension SiteObject {
//     static func refer<T: TargetIdentifying>(
//         to target: T,
//         relativity: PathRelativity
//     ) -> String {
//         target.target().output.render(as: relativity)
//     }
// }

// public extension SiteObject {
//     static func asset_reference<T: TargetIdentifying>(
//         to target: T,
//         absolute: Bool = false,
//         relativity: PathRelativity = .root
//     ) -> HTMLAssetReference {
//         let reference_path = target.target().output

//         if absolute {
//             return .raw(
//                 Self.site.compose_address(appending: reference_path)
//             )
//         }

//         return HTMLAssetReference(
//             reference_path,
//             options: .init(
//                 relativity: relativity
//             )
//         )
//     }
// }

// public extension BundleHTMLDocumentStyle {
//     static func linked<Site: SiteObject>(
//         site: Site.Type,
//         stylesheets: [Site.Stylesheet],
//         absolute: Bool = false,
//         relativity: PathRelativity = .root
//     ) -> Self {
//         .linked(
//             stylesheets.map {
//                 site.asset_reference(
//                     to: $0,
//                     absolute: absolute,
//                     relativity: relativity
//                 )
//             }
//         )
//     }
// }
