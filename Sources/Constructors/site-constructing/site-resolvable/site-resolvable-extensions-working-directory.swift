import Foundation
import Path
import Primitives

extension SiteResolvable {
    public func default_target_subdirectory(
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

extension SiteResolvable {
    // returns, say, 'www-hondenmeesters'
    // assumes standard 'www-<domain>' convention
    public func default_working_subdirectory() -> String {
        var subdir: String = ""

        switch self {
        // example special case:
        // case .my_website:
        //      subdir = "www-some-other-subdirectory"
        // case .docs_hondenmeesters: // grouped as sudomain of other domain
        //     subdir = Site.hondenmeesters.default_working_subdirectory()
        default: 
            subdir = "www" + "-" + self.rawValue
        }

        return subdir
    }

    // returns full DistributionPaths() object 
    // based on default naming conventions
    // and directory structure:
    // <root>/www-<project>/..
    // ../public/<?subdomain><?.><domain><?.><TLD>
    // ../tests/..
    public func default_dist_directory(
        root: DistributionPathsRoot = .resolve_from_env
    ) throws -> DistributionPaths {
        let default_working_subdir = default_working_subdirectory()

        let default_test_target_subdir = self.default_target_subdirectory(dist: .test)
        let default_public_target_subdir = self.default_target_subdirectory(dist: .public)

        let default_test_path = 
            default_working_subdir.ensure_leading_slash() 
            +
            default_test_target_subdir.rendered(asRootPath: true)

        let default_public_path = 
            default_working_subdir.ensure_leading_slash() 
            +
            default_public_target_subdir.rendered(asRootPath: true)

        return try DistributionPaths(
            test: default_test_path,
            public: default_public_path,
            root: root
        )
    }
}

extension SiteResolvable {
    public func dist() throws -> DistributionPaths {
        switch self {
        // case .hondenmeesters:
        //     return try .init(
        //         test: "/www-hondenmeesters/tests/test.hondenmeesters.nl",
        //         public: "/www-hondenmeesters/public/hondenmeesters.nl",
        //         root: .resolve_from_env
        //     )
        // case .docs_hondenmeesters:
        //     return try .init(
        //         test: "/www-hondenmeesters/tests/test.docs.hondenmeesters.nl",
        //         public: "/www-hondenmeesters/public/docs.hondenmeesters.nl",
        //         root: .resolve_from_env
        //     )
        // case .cynology:
        //     return try .init(
        //         test: "/www-cynology/tests/test.cynology.org",
        //         public: "/www-cynology/public/cynology.org",
        //         root: .resolve_from_env
        //     )

        // case .leviouwendijk:
        //     return try .init(
        //         test: "/www-leviouwendijk/tests/test.leviouwendijk.nl",
        //         public: "/www-leviouwendijk/public/leviouwendijk.nl",
        //         root: .resolve_from_env
        //     )
        default: 
            return try default_dist_directory()
        }
    }
}
