import Foundation

@inline(__always)
public func stderr(_ text: String) {
    FileHandle.standardError.write(Data(text.utf8))
}
