import Foundation

public enum PSQLScan {
    // Common byte helpers
    @inline(__always) private static func isASCIILetter(_ b: UInt8) -> Bool {
        (b >= 65 && b <= 90) || (b >= 97 && b <= 122) // A-Z a-z
    }
    @inline(__always) private static func isDigit(_ b: UInt8) -> Bool { b >= 48 && b <= 57 }
    @inline(__always) private static func isWord(_ b: UInt8) -> Bool {
        isASCIILetter(b) || isDigit(b) || b == 95 // underscore
    }

    // Identifier: ^[A-Za-z_][A-Za-z0-9_]*(?:\.[A-Za-z_][A-Za-z0-9_]*)?$
    public enum Ident {
        /// Returns true iff `s` matches the identifier grammar exactly:
        /// `name` or `schema.name`, where each segment is `[A-Za-z_][A-Za-z0-9_]*`.
        @inline(__always)
        public static func isValid(_ s: String) -> Bool {
            let bytes = Array(s.utf8)
            var i = 0
            // segment #1
            guard i < bytes.count else { return false }
            let f1 = bytes[i]
            guard PSQLScan.isASCIILetter(f1) || f1 == 95 else { return false }
            i += 1
            while i < bytes.count, PSQLScan.isWord(bytes[i]) { i += 1 }

            // optional (. segment2)
            if i < bytes.count {
                guard bytes[i] == 46 /* '.' */ else { return false }
                i += 1
                guard i < bytes.count else { return false }
                let f2 = bytes[i]
                guard PSQLScan.isASCIILetter(f2) || f2 == 95 else { return false }
                i += 1
                while i < bytes.count, PSQLScan.isWord(bytes[i]) { i += 1 }
            }

            // EOL
            return i == bytes.count
        }

        /// Precondition variant with a custom message (handy for init validations).
        @inline(__always)
        public static func preconditionValid(_ s: String, _ msg: @autoclosure () -> String) {
            precondition(isValid(s), msg())
        }
    }

    // Literal / comment heuristics used by unsafeRawInjection(strict:)
    public enum Heuristics {
        /// Detect `'...'` pairs (including `''`). Lone `'` does not match.
        @inline(__always)
        public static func containsQuotedLiteral(_ s: String) -> Bool {
            let bytes = Array(s.utf8)
            var i = 0
            while i < bytes.count {
                if bytes[i] == 39 { // '
                    var j = i &+ 1
                    while j < bytes.count {
                        if bytes[j] == 39 { return true } // closing quote
                        j &+= 1
                    }
                    // unmatched quote → no full `'...'` pair
                    return false
                }
                i &+= 1
            }
            return false
        }

        /// Word-bounded number: `\b\d+(\.\d+)?\b`
        @inline(__always)
        public static func containsNumericLiteral(_ s: String) -> Bool {
            let bytes = Array(s.utf8)
            let n = bytes.count
            var i = 0
            while i < n {
                let b = bytes[i]
                if PSQLScan.isDigit(b) {
                    let leftBoundary = (i == 0) || !PSQLScan.isWord(bytes[i - 1])
                    var j = i
                    while j < n, PSQLScan.isDigit(bytes[j]) { j &+= 1 }
                    if j < n, bytes[j] == 46 /* . */, (j + 1) < n, PSQLScan.isDigit(bytes[j + 1]) {
                        j &+= 1
                        while j < n, PSQLScan.isDigit(bytes[j]) { j &+= 1 }
                    }
                    let rightBoundary = (j == n) || !PSQLScan.isWord(bytes[j])
                    if leftBoundary && rightBoundary { return true }
                    i = j
                    continue
                }
                i &+= 1
            }
            return false
        }

        /// `::[A-Za-z_][A-Za-z0-9_]*`
        @inline(__always)
        public static func containsTypeCast(_ s: String) -> Bool {
            let bytes = Array(s.utf8)
            let n = bytes.count
            var i = 0
            while i + 2 < n {
                if bytes[i] == 58, bytes[i + 1] == 58 { // ::
                    let start = i + 2
                    guard start < n else { return false }
                    let f = bytes[start]
                    if !(PSQLScan.isASCIILetter(f) || f == 95) { i &+= 2; continue }
                    var j = start &+ 1
                    while j < n, PSQLScan.isWord(bytes[j]) { j &+= 1 }
                    return true
                }
                i &+= 1
            }
            return false
        }

        /// Fast check for `--` line comment marker.
        @inline(__always)
        public static func containsLineComment(_ s: String) -> Bool {
            // quick byte prefilter to avoid scanning many strings with no '-'
            guard s.utf8.contains(45) /* '-' */ else { return false }
            return s.contains("--")
        }

        /// Fast check for `/*` block comment start.
        @inline(__always)
        public static func containsBlockCommentStart(_ s: String) -> Bool {
            guard s.utf8.contains(47) /* '/' */ else { return false }
            return s.contains("/*")
        }

        /// Combined “is this likely unsafe raw SQL?” predicate used by strict injection guard.
        @inline(__always)
        public static func isUnsafeRaw(_ s: String) -> Bool {
            containsQuotedLiteral(s)
            || containsNumericLiteral(s)
            || containsTypeCast(s)
            || containsLineComment(s)
            || containsBlockCommentStart(s)
        }
    }

    // Convenience

    /// Precondition-fail if `s` looks like it contains raw literals/casts/comments.
    @inline(__always)
    public static func assertSafeRaw(_ s: String, strict: Bool = true, _ msg: @autoclosure () -> String = {
        "unsafeRawInjection(strict:true) blocked likely unparameterized literal. Use PSQL.val(...) binds instead or pass strict:false explicitly."
    }()) {
        guard strict else { return }
        precondition(!Heuristics.isUnsafeRaw(s), msg())
    }
}
