import Foundation
import Path
import ProtocolComponents
import Primitives

public extension SiteResolvable {
    var site_id: String { rawValue }
}

public extension SiteResolvable {
    var protocol_component: HTTPProtocolComponent? {
        return .https
    }

    var tld_component: TopLevelDomainComponent? {
        return .nl
    }

    var web_root_component: String {
        return self.rawValue.replacingUnderscores()
    }
}

public extension SiteResolvable {
    func compose_address(
        appending path: GenericPath? = nil
    ) -> String {
        var res: [String] = []
        if let p = protocol_component {
            res.append(p.component)
        }
        res.append(web_root_component)
        if let tld = tld_component {
            res.append(tld.component)
        }
        
        if let path {
            res.append(path.rendered(asRootPath: true))
        } else {
            var str = res.joined()
            if !str.hasSuffix("/") {
                str.append("/")
            }
            return str
        }

        var str = res.joined()

        if str.hasSuffix("/index.html") {
            str.removeLast("index.html".count)
        }

        return str
    }

    func address(
        for identifier: (any TargetIdentifying)? = nil
    ) -> String {
        let path: GenericPath? = identifier?.target().output
        return self.compose_address(appending: path)
    }

    func root_address() -> String {
        return address(for: nil)
    }
}
