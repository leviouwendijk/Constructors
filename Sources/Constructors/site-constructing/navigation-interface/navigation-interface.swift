import Foundation
import Primitives
import HTML
import Path

public struct NavigationInterface: Sendable {
    public struct Node: Sendable, Hashable {
        public var label: String
        public var path: String?
        public var children: [Node]

        public init(
            label: String,
            path: String? = nil,
            children: [Node] = []
        ) {
            self.label = label
            self.path = path
            self.children = children
        }

        public var isLeaf: Bool {
            path != nil && children.isEmpty
        }

        public var hasChildren: Bool {
            !children.isEmpty
        }
    }

    public var roots: [Node]

    public init(roots: [Node] = []) {
        self.roots = roots
    }
}

public struct NavEntry: Sendable {
    public let segments: [String]  // e.g. ["Problemen", "Uitvallen"]
    public let path: String        // href, like "/problemen/uitvallen.html"
}

public extension NavigationInterface {
    static func build(
        from pages: [String : PageTarget],
        env: BuildEnvironment
    ) -> NavigationInterface {
        NavigationInterface.build(from: pages) { target in
            let visible = target.visibility.isEmpty || target.visibility.contains(env)
            guard visible else { return false }

            switch target.navigation {
            case .none: return false
            case .auto, .custom: return true
            }
        }
    }

    /// Build tree from all page targets.
    ///
    /// - pages: your `SitePages.pages()`
    /// - include: env filter (e.g. hide .local/.test)
    static func build(
        from pages: [PageTarget],
        include: (PageTarget) -> Bool
    ) -> NavigationInterface {
        var entries: [NavEntry] = []

        for target in pages {
            guard include(target) else { continue }

            let href = target.output.rendered(asRootPath: true)
            // e.g. "/problemen/uitvallen.html"

            switch target.navigation {
            case .none:
                continue

            case .custom(let segments):
                guard !segments.isEmpty else { continue }
                entries.append(NavEntry(segments: segments, path: href))

            case .auto(let options):
                let segs = autoSegments(for: target.output, options: options)
                guard !segs.isEmpty else { continue }
                entries.append(NavEntry(segments: segs, path: href))
            }
        }

        let roots = buildTree(from: entries)
        return NavigationInterface(roots: roots)
    }

    // see func above
    @available(*, message: "can use the other arrayPages() version if desired to be ketp around")
    static func build(
        from pages: [String : PageTarget],
        include: (PageTarget) -> Bool
    ) -> NavigationInterface {
        var entries: [NavEntry] = []

        for (_, target) in pages {
            guard include(target) else { continue }

            let href = target.output.rendered(asRootPath: true)
            // e.g. "/problemen/uitvallen.html"

            switch target.navigation {
            case .none:
                continue

            case .custom(let segments):
                guard !segments.isEmpty else { continue }
                entries.append(NavEntry(segments: segments, path: href))

            case .auto(let options):
                let segs = autoSegments(for: target.output, options: options)
                guard !segs.isEmpty else { continue }
                entries.append(NavEntry(segments: segs, path: href))
            }
        }

        let roots = buildTree(from: entries)
        return NavigationInterface(roots: roots)
    }

    // MARK: - auto label derivation

    private static func autoSegments(
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

    private static func normalizeLabel(
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

    // MARK: - tree assembly

    private static func buildTree(from entries: [NavEntry]) -> [Node] {
        var rootsByLabel: [String : Node] = [:]

        func insert(_ entry: NavEntry) {
            guard let firstLabel = entry.segments.first else { return }

            func insertInto(node: inout Node, at index: Int) {
                if index == entry.segments.count - 1 {
                    // leaf
                    node.path = entry.path
                    return
                }

                let nextLabel = entry.segments[index + 1]

                if let idx = node.children.firstIndex(where: { $0.label == nextLabel }) {
                    var child = node.children[idx]
                    insertInto(node: &child, at: index + 1)
                    node.children[idx] = child
                } else {
                    var child = Node(label: nextLabel, path: nil, children: [])
                    insertInto(node: &child, at: index + 1)
                    node.children.append(child)
                }
            }

            if var root = rootsByLabel[firstLabel] {
                insertInto(node: &root, at: 0)
                rootsByLabel[firstLabel] = root
            } else {
                var root = Node(label: firstLabel, path: nil, children: [])
                insertInto(node: &root, at: 0)
                rootsByLabel[firstLabel] = root
            }
        }

        entries.forEach(insert)

        // deterministic ordering; you can tweak to sort by path or manually later
        return rootsByLabel.values.sorted { $0.label < $1.label }
    }
}
