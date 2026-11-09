public extension ReusableComponent {
    var export: RenderBundle.ExportAPI {
        get throws {
            try bundle().export
        }
    }
}
