import Foundation
import Path
import ProtocolComponents
import Primitives

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
    func default_target_subdirectory(
        dist: BuildEnvironment
    ) -> StandardPath {
        if dist == .local {
            fputs("Warning: invoking default_target_subdirectory() using .local results in an unused target path that does not exist.", stderr)
            fputs("This path should not be reached when using .local as your input.", stderr)
        }
        
        var strs: [String] = [
            // dist.rawValue, // test or public ( local irrelevant )
            dist.target_subdir(), // tests or public ( local irrelevant )
        ]

        var target = ""
        if dist == .test {
            target.append("test.")
        }

        target.append(web_root_component) 

        // if a non-nil TLD, append TLD
        // kept nillable in case you don't want to add it in some paths (non-web targets)
        if let tld = tld_component {
            target.append(tld.component)
        }

        strs.append(target) // either test.<hondenmeesters.nl> or without test

        // results in, say, /public/docs.hondenmeesters.nl
        // this we can then use from a standard root like `www-hondenmeesters`
        // to achieve dynamic computation of: /www-hondenmeesters/public/docs.hondenmeestesr.nl
        return StandardPath(strs) 
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
