import Foundation

public enum HTMLSpec {
    public static let void: Set<String> = [
        "area","base","br","col","embed","hr","img","input","link",
        "meta","param","source","track","wbr"
    ]

    @inline(__always) public static func isVoid(_ tag: String) -> Bool { void.contains(tag) }
}

@available(*, message: "Replaced by HTMLSpec.void / .isVoid")
public let HTMLVoidTags: Set<String> = [
    "area","base","br","col","embed","hr","img","input","link","meta","param","source","track","wbr"
]
