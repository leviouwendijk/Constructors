import Foundation

public enum PSQLInferPrototype {
    public enum PrototypeInferenceError: Error, LocalizedError {
        case cannotSynthesize(String)

        public var errorDescription: String? { "Cannot synthesize default instance for \(self)" }
    }

    public static func make<T: Decodable>(_ type: T.Type) throws -> T {
        // Fast-path builtins
        if type == String.self     { return "" as! T }
        if type == Substring.self  { return Substring("") as! T }
        if type == Int.self        { return 0 as! T }
        if type == Int8.self       { return 0 as! T }
        if type == Int16.self      { return 0 as! T }
        if type == Int32.self      { return 0 as! T }
        if type == Int64.self      { return 0 as! T }
        if type == UInt.self       { return 0 as! T }
        if type == UInt8.self      { return 0 as! T }
        if type == UInt16.self     { return 0 as! T }
        if type == UInt32.self     { return 0 as! T }
        if type == UInt64.self     { return 0 as! T }
        if type == Bool.self       { return false as! T }
        if type == Double.self     { return 0.0 as! T }
        if type == Float.self      { return 0.0 as! T }
        if type == Decimal.self    { return Decimal(0) as! T }
        if type == Date.self       { return Date(timeIntervalSince1970: 0) as! T }
        if type == UUID.self       { return UUID(uuidString: "00000000-0000-0000-0000-000000000000") as! T }
        if type == Data.self       { return Data() as! T }

        // Fallback: ask the type to decode itself from a decoder that supplies defaults
        return try T(from: _DefaultingDecoder())
    }
}

fileprivate struct _DefaultingDecoder: Decoder {
    let codingPath: [CodingKey] = []
    let userInfo: [CodingUserInfoKey : Any] = [:]

    func container<Key>(keyedBy: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
        KeyedDecodingContainer(_DefaultingKeyedContainer<Key>())
    }
    func unkeyedContainer() throws -> UnkeyedDecodingContainer { _DefaultingUnkeyedContainer() }
    func singleValueContainer() throws -> SingleValueDecodingContainer { _DefaultingSingleValueContainer() }
}

fileprivate struct _DefaultingKeyedContainer<Key: CodingKey>: KeyedDecodingContainerProtocol {
    var codingPath: [CodingKey] = []
    var allKeys: [Key] = []

    func contains(_ key: Key) -> Bool { true } // pretend every key exists

    func decodeNil(forKey key: Key) throws -> Bool { false } // non-nil by default

    func decode(_ type: Bool.Type,   forKey key: Key) throws -> Bool   { false }
    func decode(_ type: String.Type, forKey key: Key) throws -> String { "" }
    func decode(_ type: Double.Type, forKey key: Key) throws -> Double { 0.0 }
    func decode(_ type: Float.Type,  forKey key: Key) throws -> Float  { 0.0 }
    func decode(_ type: Int.Type,    forKey key: Key) throws -> Int    { 0 }
    func decode(_ type: Int8.Type,   forKey key: Key) throws -> Int8   { 0 }
    func decode(_ type: Int16.Type,  forKey key: Key) throws -> Int16  { 0 }
    func decode(_ type: Int32.Type,  forKey key: Key) throws -> Int32  { 0 }
    func decode(_ type: Int64.Type,  forKey key: Key) throws -> Int64  { 0 }
    func decode(_ type: UInt.Type,   forKey key: Key) throws -> UInt   { 0 }
    func decode(_ type: UInt8.Type,  forKey key: Key) throws -> UInt8  { 0 }
    func decode(_ type: UInt16.Type, forKey key: Key) throws -> UInt16 { 0 }
    func decode(_ type: UInt32.Type, forKey key: Key) throws -> UInt32 { 0 }
    func decode(_ type: UInt64.Type, forKey key: Key) throws -> UInt64 { 0 }

    func decode<T>(_ type: T.Type, forKey key: Key) throws -> T where T : Decodable {
        // Optionals must be non-nil here (decodeNil returned false).
        // Build default recursively.
        try PSQLInferPrototype.make(T.self)
    }

    func nestedContainer<NestedKey>(keyedBy: NestedKey.Type, forKey key: Key)
        throws -> KeyedDecodingContainer<NestedKey> {
        KeyedDecodingContainer(_DefaultingKeyedContainer<NestedKey>())
    }
    func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
        _DefaultingUnkeyedContainer()
    }
    func superDecoder() throws -> Decoder { _DefaultingDecoder() }
    func superDecoder(forKey key: Key) throws -> Decoder { _DefaultingDecoder() }
}

fileprivate struct _DefaultingUnkeyedContainer: UnkeyedDecodingContainer {
    var codingPath: [CodingKey] = []
    var count: Int? = 0
    var isAtEnd: Bool = true
    var currentIndex: Int = 0

    mutating func decodeNil() throws -> Bool { false }

    mutating func decode(_ type: Bool.Type)   throws -> Bool   { false }
    mutating func decode(_ type: String.Type) throws -> String { "" }
    mutating func decode(_ type: Double.Type) throws -> Double { 0.0 }
    mutating func decode(_ type: Float.Type)  throws -> Float  { 0.0 }
    mutating func decode(_ type: Int.Type)    throws -> Int    { 0 }
    mutating func decode(_ type: Int8.Type)   throws -> Int8   { 0 }
    mutating func decode(_ type: Int16.Type)  throws -> Int16  { 0 }
    mutating func decode(_ type: Int32.Type)  throws -> Int32  { 0 }
    mutating func decode(_ type: Int64.Type)  throws -> Int64  { 0 }
    mutating func decode(_ type: UInt.Type)   throws -> UInt   { 0 }
    mutating func decode(_ type: UInt8.Type)  throws -> UInt8  { 0 }
    mutating func decode(_ type: UInt16.Type) throws -> UInt16 { 0 }
    mutating func decode(_ type: UInt32.Type) throws -> UInt32 { 0 }
    mutating func decode(_ type: UInt64.Type) throws -> UInt64 { 0 }

    mutating func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
        try PSQLInferPrototype.make(T.self)
    }

    mutating func nestedContainer<NestedKey>(keyedBy: NestedKey.Type)
        throws -> KeyedDecodingContainer<NestedKey> {
        KeyedDecodingContainer(_DefaultingKeyedContainer<NestedKey>())
    }
    mutating func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer { self }
    mutating func superDecoder() throws -> Decoder { _DefaultingDecoder() }
}

fileprivate struct _DefaultingSingleValueContainer: SingleValueDecodingContainer {
    var codingPath: [CodingKey] = []

    func decodeNil() -> Bool { false }

    func decode(_ type: Bool.Type)   throws -> Bool   { false }
    func decode(_ type: String.Type) throws -> String { "" }
    func decode(_ type: Double.Type) throws -> Double { 0.0 }
    func decode(_ type: Float.Type)  throws -> Float  { 0.0 }
    func decode(_ type: Int.Type)    throws -> Int    { 0 }
    func decode(_ type: Int8.Type)   throws -> Int8   { 0 }
    func decode(_ type: Int16.Type)  throws -> Int16  { 0 }
    func decode(_ type: Int32.Type)  throws -> Int32  { 0 }
    func decode(_ type: Int64.Type)  throws -> Int64  { 0 }
    func decode(_ type: UInt.Type)   throws -> UInt   { 0 }
    func decode(_ type: UInt8.Type)  throws -> UInt8  { 0 }
    func decode(_ type: UInt16.Type) throws -> UInt16 { 0 }
    func decode(_ type: UInt32.Type) throws -> UInt32 { 0 }
    func decode(_ type: UInt64.Type) throws -> UInt64 { 0 }

    func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
        try PSQLInferPrototype.make(T.self)
    }
}
