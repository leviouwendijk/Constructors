import Foundation
// import ArgumentParser
import Primitives
import Writers

public protocol BuildEnvironmentReturning: Sendable {
    func env() -> BuildEnvironment
}

// public enum DistributionType: String, Sendable, ExpressibleByArgument {
extension BuildEnvironment {
    public func target_subdir() -> String {
        switch self {
        case .test:
            return self.rawValue + "s"
        default:
            return self.rawValue
        }
    }

    // public func base_url(for site: Site) throws -> URL {
    public func base_url(for site: any SiteResolvable) throws -> URL {
        let dist_paths = try site.dist()

        switch self {
        case .local:
            return URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
            .appendingPathComponent("dist")
            .appendingPathComponent(site.rawValue)

        case .test:
            return URL(fileURLWithPath: dist_paths.test)

        case .public:
            return URL(fileURLWithPath: dist_paths.public)
        }
    }

    public func write(content: String, to url: URL) throws -> Void {
        switch self {
        case .local:
            try content.write(to: url, atomically: true, encoding: .utf8)

        case .test:
            try content.write(to: url, atomically: true, encoding: .utf8)

        case .public:
            // Safe write with backup + atomic replace
            let opts = SafeWriteOptions(
                overrideExisting: true,            // allow overwrite in public dist
                makeBackupOnOverride: true,        // create a backup before overwriting
                whitespaceOnlyIsBlank: true,       // treat whitespace-only files as blank
                backupSuffix: "_previous_version.bak",
                addTimestampIfBackupExists: true,  // avoid clobbering an existing backup
                createIntermediateDirectories: true,
                atomic: true,
                maxBackupSets: 10
            )
            _ = try SafeFile(url).write(content, options: opts)
        }
    }

    public func pull_assets(for site: any SiteResolvable) throws -> Void {
        switch self {
        case .test:
            // copy from public → test
            let dist_paths = try site.dist()
            let dstRoot = URL(fileURLWithPath: dist_paths.test, isDirectory: true)
            try syncCopyableResourcesFromPublic(site: site, to: dstRoot, makeBackupsOnOverwrite: false)

        case .local:
            // mirror from public → local build output if you want
            let dstRoot = try self.base_url(for: site)
            try syncCopyableResourcesFromPublic(site: site, to: dstRoot, makeBackupsOnOverwrite: false)
            break

        case .public:
            break
        }
    }
}
