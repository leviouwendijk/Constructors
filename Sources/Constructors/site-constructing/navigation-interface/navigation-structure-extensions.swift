import Foundation
import Primitives
import HTML
import Path

extension NavigationStructure {
    internal static func autoSegments(
        for path: ProjectPath,
        options: NavigationRenderOptions
    ) -> [String] {
        let rawSegments = path.segments.map { $0.value }   // ["problemen", "uitvallen.html"]
        guard let last = rawSegments.last else { return [] }

        let dirs = Array(rawSegments.dropLast())
        let isIndex = last == "index.html"
        let baseName = last.replacingOccurrences(of: ".html", with: "")

        func label(_ raw: String) -> String {
            normalizeLabel(raw, options: options)
        }

        // Root index: make them explicit via .custom if you want "Home"
        if dirs.isEmpty && isIndex {
            return [label("index")]
        }

        if isIndex {
            // /problemen/index.html → ["Problemen"]
            if let lastDir = dirs.last {
                return [label(lastDir)]
            } else {
                return [label(baseName)]
            }
        }

        // Non-index page:
        //  /problemen/uitvallen.html → ["Problemen", "Uitvallen"] (with default opts)
        var result: [String] = []
        result.append(contentsOf: dirs.map(label))
        result.append(label(baseName))
        return result
    }

    internal static func normalizeLabel(
        _ raw: String,
        options: NavigationRenderOptions
    ) -> String {
        // 1) strip extension
        let base: String
        if let dotIndex = raw.firstIndex(of: ".") {
            base = String(raw[..<dotIndex])
        } else {
            base = raw
        }

        // 2) replace space_chars with spaces
        var working = base
        for ch in options.space_chars {
            working = working.replacingOccurrences(of: ch, with: " ")
        }

        // 3) collapse multiple spaces
        working = working
            .split(whereSeparator: { $0.isWhitespace })
            .map(String.init)
            .joined(separator: " ")

        guard !working.isEmpty else { return raw }

        // 4) capitalization
        switch options.capitalization {
        case .per_word:
            // "privacy beleid" → "Privacy Beleid"
            return working
                .split(separator: " ")
                .map { word -> String in
                    let w = word.lowercased()
                    guard let first = w.first else { return "" }
                    if w.count == 1 { return w.uppercased() }
                    return String(first).uppercased() + w.dropFirst()
                }
                .joined(separator: " ")

        case .first_word:
            // "privacy beleid" → "Privacy beleid"
            var chars = Array(working.lowercased())
            guard let first = chars.first else { return working }
            chars[0] = Character(String(first).uppercased())
            return String(chars)
        }
    }
}

public extension NavigationStructure {
    /// Build tree from all page targets.
    ///
    /// - pages: your `SitePages.pages()`
    /// - include: env filter (e.g. hide .local/.test)
    static func build(
        from pages: [PageTarget],
        include: (PageTarget) -> Bool,
        sort_order: NavigationSortOrder = .insertion
    ) -> NavigationStructure {
        var entries: [NavigationEntry] = []

        for target in pages {
            guard include(target) else { continue }

            let href = target.output.rendered(asRootPath: true)

            switch target.navigation {
            case .none:
                continue

            case .custom(let segments):
                guard !segments.isEmpty else { continue }
                entries.append(NavigationEntry(segments: segments, path: href))

            case .auto(let options):
                let segs = autoSegments(for: target.output, options: options)
                guard !segs.isEmpty else { continue }
                entries.append(NavigationEntry(segments: segs, path: href))
            }
        }

        let roots = buildTree(from: entries, sort_order: sort_order)
        return NavigationStructure(roots: roots)
    }

    private static func buildTree(
        from entries: [NavigationEntry],
        sort_order: NavigationSortOrder
    ) -> [NavigationNode] {
        var rootsByLabel: [String : NavigationNode] = [:]
        var root_order: [String] = []

        func insert(_ entry: NavigationEntry) {
            guard let firstLabel = entry.segments.first else { return }

            func insertInto(node: inout NavigationNode, at index: Int) {
                if index == entry.segments.count - 1 {
                    node.path = entry.path
                    return
                }

                let nextLabel = entry.segments[index + 1]

                if let idx = node.children.firstIndex(where: { $0.label == nextLabel }) {
                    var child = node.children[idx]
                    insertInto(node: &child, at: index + 1)
                    node.children[idx] = child
                } else {
                    var child = NavigationNode(label: nextLabel, path: nil, children: [])
                    insertInto(node: &child, at: index + 1)
                    node.children.append(child)
                }
            }

            if var root = rootsByLabel[firstLabel] {
                insertInto(node: &root, at: 0)
                rootsByLabel[firstLabel] = root
            } else {
                var root = NavigationNode(label: firstLabel, path: nil, children: [])
                insertInto(node: &root, at: 0)
                rootsByLabel[firstLabel] = root
                root_order.append(firstLabel)
            }
        }

        entries.forEach(insert)

        switch sort_order {
        case .insertion:
            return root_order.compactMap { rootsByLabel[$0] }

        case .alphabetical:
            var roots = root_order.compactMap { rootsByLabel[$0] }

            func sortRec(_ nodes: inout [NavigationNode]) {
                nodes.sort { $0.label < $1.label }
                for i in nodes.indices {
                    sortRec(&nodes[i].children)
                }
            }

            sortRec(&roots)
            return roots
        }
    }
}

public extension NavigationStructure {
    static func build(
        from pages: [String : PageTarget],
        env: BuildEnvironment,
        sort_order: NavigationSortOrder = .insertion
    ) -> NavigationStructure {
        NavigationStructure.build(from: pages, sort_order: sort_order) { target in
            let visible = target.visibility.isEmpty || target.visibility.contains(env)
            guard visible else { return false }

            switch target.navigation {
            case .none: return false
            case .auto, .custom: return true
            }
        }
    }


    @available(*, message: "can use the other arrayPages() version if desired to be ketp around")
    static func build(
        from pages: [String : PageTarget],
        sort_order: NavigationSortOrder = .alphabetical,
        include: (PageTarget) -> Bool
    ) -> NavigationStructure {
        var entries: [NavigationEntry] = []

        for (_, target) in pages {
            guard include(target) else { continue }

            let href = target.output.rendered(asRootPath: true)

            switch target.navigation {
            case .none:
                continue

            case .custom(let segments):
                guard !segments.isEmpty else { continue }
                entries.append(NavigationEntry(segments: segments, path: href))

            case .auto(let options):
                let segs = autoSegments(for: target.output, options: options)
                guard !segs.isEmpty else { continue }
                entries.append(NavigationEntry(segments: segs, path: href))
            }
        }

        let roots = buildTree(from: entries, sort_order: sort_order)
        return NavigationStructure(roots: roots)
    }
}
