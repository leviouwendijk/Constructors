public extension MetadataTargetable {
    var metadata: TargetMetadata { .default }
}

public extension TargetIdentifying where TargetType: MetadataTargetable {
    var metadata: TargetMetadata { target().metadata }
}
