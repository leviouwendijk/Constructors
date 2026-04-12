import Path

public func resolve_site_reference(
    sourceSite: any SiteResolvable,
    destinationSite: any SiteResolvable,
    path: StandardPath,
    style: SiteReferenceStyle
) -> String {
    switch style {
    case .absolute:
        return destinationSite.compose_address(
            appending: path
        )

    case .local(let relativity):
        return path.render(
            as: relativity
        )

    case .automatic:
        if sourceSite.site_id == destinationSite.site_id {
            return path.render(
                as: .root
            )
        }

        return destinationSite.compose_address(
            appending: path
        )
    }
}

public func resolve_site_asset_reference(
    sourceSite: any SiteResolvable,
    destinationSite: any SiteResolvable,
    path: StandardPath,
    style: SiteReferenceStyle
) -> HTMLAssetReference {
    switch style {
    case .absolute:
        return .raw(
            destinationSite.compose_address(
                appending: path
            )
        )

    case .local(let relativity):
        return HTMLAssetReference(
            path,
            options: .init(
                relativity: relativity
            )
        )

    case .automatic:
        if sourceSite.site_id == destinationSite.site_id {
            return HTMLAssetReference(
                path,
                options: .root
            )
        }

        return .raw(
            destinationSite.compose_address(
                appending: path
            )
        )
    }
}
