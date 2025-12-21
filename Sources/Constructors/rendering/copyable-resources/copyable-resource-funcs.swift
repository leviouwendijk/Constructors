import Foundation
import Writers

public let skipNames: Set<String> = [".DS_Store"]

public extension CopyableResource {
    var relativePath: String { self.rawValue }
    var isDirectory: Bool { self == .assets }
}

@discardableResult
public func copyIfDifferent(src: URL, dst: URL, backups: Bool) throws -> Bool {
    let fm = FileManager.default
    var shouldCopy = false

    if !fm.fileExists(atPath: dst.path) {
        shouldCopy = true
    } else {
        let sa = try fm.attributesOfItem(atPath: src.path)
        let da = try fm.attributesOfItem(atPath: dst.path)
        let sSize = (sa[.size] as? NSNumber)?.uint64Value ?? 0
        let dSize = (da[.size] as? NSNumber)?.uint64Value ?? UInt64.max
        let sMod  = (sa[.modificationDate] as? Date) ?? .distantPast
        let dMod  = (da[.modificationDate] as? Date) ?? .distantFuture
        shouldCopy = (sSize != dSize) || (sMod > dMod)
    }

    guard shouldCopy else { return false }

    let data = try Data(contentsOf: src, options: .uncached)
    let opts = SafeWriteOptions(
        overrideExisting: true,
        makeBackupOnOverride: backups,
        whitespaceOnlyIsBlank: false,
        backupSuffix: "_previous_version.bak",
        addTimestampIfBackupExists: true,
        createIntermediateDirectories: true,
        atomic: true
    )
    _ = try SafeFile(dst).write(data, options: opts)
    return true
}

func syncCopyableResourcesFromPublic(
    // site: Site,
    site: any SiteResolvable,
    to targetRoot: URL,
    copyables: [CopyableResource]? = nil,
    makeBackupsOnOverwrite: Bool = true
) throws {
    let fm = FileManager.default
    let dist_paths = try site.dist()
    let srcRoot = URL(fileURLWithPath: dist_paths.public, isDirectory: true)
    let items = copyables ?? site.copyables_from_public()

    for item in items {
        let rel = item.relativePath
        let src = srcRoot.appendingPathComponent(rel, isDirectory: item.isDirectory)
        let dst = targetRoot.appendingPathComponent(rel, isDirectory: item.isDirectory)

        guard fm.fileExists(atPath: src.path) else { continue }

        if item.isDirectory {
            // Mirror directory tree (e.g., assets/)
            let en = fm.enumerator(
                at: src,
                includingPropertiesForKeys: [.isDirectoryKey],
                options: [.skipsHiddenFiles]
            )!
            for case let url as URL in en {
                if skipNames.contains(url.lastPathComponent) { continue }
                let relPath = url.path.dropFirst(src.path.count).trimmingCharacters(in: CharacterSet(charactersIn: "/"))
                let dstURL = dst.appendingPathComponent(String(relPath), isDirectory: false)

                let v = try url.resourceValues(forKeys: [.isDirectoryKey])
                if v.isDirectory == true {
                    try fm.createDirectory(at: dstURL, withIntermediateDirectories: true)
                    continue
                }
                _ = try copyIfDifferent(src: url, dst: dstURL, backups: makeBackupsOnOverwrite)
            }
        } else {
            // Single file (robots.txt, site.webmanifest, sitemap.xml)
            try fm.createDirectory(at: dst.deletingLastPathComponent(), withIntermediateDirectories: true)
            _ = try copyIfDifferent(src: src, dst: dst, backups: makeBackupsOnOverwrite)
        }
    }
}
