public extension RenderBundle {
    struct ExportAPI {
        public let bundle: RenderBundle

        public init(
            bundle: RenderBundle
        ) {
            self.bundle = bundle
        }

        public var document: DocumentAPI {
            DocumentAPI(bundle: bundle)
        }

        public var fragment: FragmentAPI {
            FragmentAPI(bundle: bundle)
        }

        // Compatibility aliases
        public var html: DocumentAPI.HTMLAPI {
            document.html
        }

        public var css: DocumentAPI.CSSAPI {
            document.css
        }

        public var js: DocumentAPI.JSAPI {
            document.js
        }
    }

    var export: ExportAPI {
        ExportAPI(bundle: self)
    }
}

public extension RenderBundle.ExportAPI {
    struct DocumentAPI {
        public let bundle: RenderBundle

        public init(
            bundle: RenderBundle
        ) {
            self.bundle = bundle
        }

        public var html: HTMLAPI {
            HTMLAPI(bundle: bundle)
        }

        public var css: CSSAPI {
            CSSAPI(bundle: bundle)
        }

        public var js: JSAPI {
            JSAPI(bundle: bundle)
        }
    }

    struct FragmentAPI {
        public let bundle: RenderBundle

        public init(
            bundle: RenderBundle
        ) {
            self.bundle = bundle
        }

        public var html: HTMLAPI {
            HTMLAPI(bundle: bundle)
        }
    }
}
