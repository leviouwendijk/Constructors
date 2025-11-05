import Foundation
import Structures

// public typealias PSQLFieldTypeRegistry = FieldTypeRegistry<PSQLType>

// public enum PSQLFieldTypes {
public enum PSQLFieldTypeRegistry {
    public static let shared = FieldTypeRegistry<PSQLType>()

    public static func register(
        table name: String,
        types: [String: PSQLType],
        overwrite: Bool = false
    ) async -> Void {
        await shared.register(table: name, types: types, overwrite: overwrite)
    }

    public static func merge(table name: String, patch: [String: PSQLType]) async {
        await shared.merge(table: name, patch: patch)
    }

    public static func upsert(table name: String, key: String, type: PSQLType) async {
        await shared.upsert(table: name, key: key, value: type)
    }

    public static func remove(table name: String) async {
        await shared.remove(table: name)
    }

    public static func remove(table name: String, key: String) async {
        await shared.remove(table: name, key: key)
    }

    public static func table(named name: String) async throws -> [String: PSQLType] {
        try await shared.table(named: name)
    }

    public static func value(in table: String, for key: String) async throws -> PSQLType {
        try await shared.value(in: table, for: key)
    }

    public static func snapshot() async -> [String: [String: PSQLType]] {
        await shared.snapshot()
    }

    public static func contains(table name: String) async -> Bool {
        await shared.contains(table: name)
    }

    public static func contains(table name: String, key: String) async -> Bool {
        await shared.contains(table: name, key: key)
    }

    public static func tables() async -> [String] {
        await shared.tables()
    }

    public static func keys(in table: String) async -> [String] {
        await shared.keys(in: table)
    }
}
