import Foundation

public enum PSQLType: Codable, Sendable {
    case smallInt                     // SMALLINT
    case integer                      // INTEGER
    case bigInt                       // BIGINT
    case serial                       // SERIAL
    case bigSerial                    // BIGSERIAL
    case real                         // REAL (float4)
    case doublePrecision              // DOUBLE PRECISION (float8)
    case numeric(precision: Int?, scale: Int?) // NUMERIC(p,s) / DECIMAL

    case text                         // TEXT
    case varchar(length: Int?)       // VARCHAR(n)
    case char(length: Int?)          // CHAR(n)

    case date                         // DATE
    case time                         // TIME WITHOUT TIME ZONE
    case timeTZ                       // TIME WITH TIME ZONE
    case timestamp                    // TIMESTAMP WITHOUT TIME ZONE
    case timestamptz                  // TIMESTAMP WITH TIME ZONE
    case interval                     // INTERVAL

    case boolean                      // BOOLEAN
    case bytea                        // BYTEA
    case uuid                         // UUID
    case json                         // JSON
    case jsonb                        // JSONB
    case inet                         // INET
    case cidr                         // CIDR
    case macaddr                      // MACADDR

    indirect case array(of: PSQLType)          // Any PostgreSQL array type

    case tsvector                     // TSVECTOR
    case tsquery                      // TSQUERY

    case xml                          // XML
    case custom(dbType: String)       // Domains, enums, PostGIS, etc.

    public func convert() -> String {
        switch self {
        case .smallInt:          return "::smallint"
        case .integer:           return "::integer"
        case .bigInt:            return "::bigint"
        case .serial:            return "::serial"
        case .bigSerial:         return "::bigserial"
        case .real:              return "::real"
        case .doublePrecision:   return "::double precision"
        case .numeric(let p, let s):
            if let p = p, let s = s { return "::numeric(\(p),\(s))" }
            else { return "::numeric" }
        case .text:              return "::text"
        case .varchar(let n):    return n.map { "::varchar(\($0))" } ?? "::varchar"
        case .char(let n):       return n.map { "::char(\($0))" } ?? "::char"
        case .date:              return "::date"
        case .time:              return "::time"
        case .timeTZ:            return "::timetz"
        case .timestamp:         return "::timestamp"
        case .timestamptz:       return "::timestamptz"
        case .interval:          return "::interval"
        case .boolean:           return "::boolean"
        case .bytea:             return "::bytea"
        case .uuid:              return "::uuid"
        case .json:              return "::json"
        case .jsonb:             return "::jsonb"
        case .inet:              return "::inet"
        case .cidr:              return "::cidr"
        case .macaddr:           return "::macaddr"
        case .array(let element):
            let inner = element.convert().trimmingCharacters(in: CharacterSet(charactersIn: ":"))
            return "::\(inner)[]"
        case .tsvector:          return "::tsvector"
        case .tsquery:           return "::tsquery"
        case .xml:               return "::xml"
        case .custom(let dbType):return "::\(dbType)"
        }
    }

    public static func typeCast(_ type: PSQLType) -> String {
        return type.convert()
    }

    public var sqlCast: String { Self.typeCast(self) }
}
