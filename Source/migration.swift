#if os(OSX) || os(iOS) || os(watchOS) || os(tvOS)
    import Darwin
#elseif os(Linux)
    import Glibc
#endif

public enum MigrationColumnType :Int
{
    case VARCHAR
    case SMALLINT
    case MEDIUMINT
    case INT
    case BIGINT
    case DECIMAL
    case TEXT
    case DOUBLE
    case FLOAT
    case DATE
    case DATETIME
    case TIMESTAMP
    case TIME
    case ENUM
    case SET

    public func toString(constraint :String? = nil) -> String
    {
        var type :String
        switch self
        {
        case .VARCHAR:
            type = "VARCHAR"
            break
        case .SMALLINT:
            type = "SMALLINT"
            break
        case .MEDIUMINT:
            type = "MEDIUMINT"
            break
        case .INT:
            type = "INT"
            break
        case .BIGINT:
            type = "BIGINT"
            break
        case .DECIMAL:
            type = "DECIMAL"
            break
        case .TEXT:
            type = "TEXT"
            break
        case .DOUBLE:
            type = "DOUBLE"
            break
        case .FLOAT:
            type = "FLOAT"
            break
        case .DATE:
            type = "DATE"
            break
        case .DATETIME:
            type = "DATETIME"
            break
        case .TIMESTAMP:
            type = "TIMESTAMP"
            break
        case .TIME:
            type = "TIME"
            break
        case .ENUM:
            type = "ENUM"
            break
        case .SET:
            type = "SET"
            break
        }
        if let constraint = constraint
        {
            type += "(\(constraint))"
        }
        return type
    }
}

public struct MigrationColumn
{
    var name :String
    var columnType :MigrationColumnType
    var constraint :String? = nil
    var unique :Bool = false
    var primaryKey :Bool = false
    var autoIncrement :Bool = false
    var unsigned :Bool = false
    var nullable :Bool = false

    public init(name :String, columnType :MigrationColumnType, constraint :String? = nil)
    {
        self.name = name
        self.columnType = columnType
        self.constraint = constraint
    }

    public init(name :String, columnType :MigrationColumnType, constraint :String?, primaryKey :Bool, autoIncrement :Bool)
    {
        self.name = name
        self.columnType = columnType
        self.constraint = constraint
        self.primaryKey = primaryKey
        self.autoIncrement = autoIncrement
        self.unsigned = true
        self.nullable = false
    }
    public init(name :String, columnType :MigrationColumnType, constraint :String?, nullable :Bool)
    {
        self.name = name
        self.columnType = columnType
        self.constraint = constraint
        self.nullable = nullable
        self.primaryKey = false
        self.unique = false
        self.autoIncrement = false
        self.unsigned = false
    }
    public init(name :String, columnType :MigrationColumnType, constraint :String?, unique: Bool)
    {
        self.name = name
        self.columnType = columnType
        self.constraint = constraint
        self.unique = false
        self.unsigned = true
        self.primaryKey = false
        self.autoIncrement = false
        self.nullable = false
    }

    public func toString() -> String
    {
        var result :String = "\(name) \(columnType.toString(constraint))"
        if unsigned
        {
            result += " UNSIGNED"
        }
        if nullable
        {
            result += " NULL"
        } else if primaryKey
        {
            result += " PRIMARY KEY"
        } else if unique
        {
            result += " UNIQUE"
        }
        if autoIncrement
        {
            result += " AUTO_INCREMENT"
        }
        return result
    }
}

public protocol MigrationTypeProtocol {
    var tableName :String { get }
    func toSQL() -> String
}
public struct MigrationTypeCreate :MigrationTypeProtocol {
    public var tableName :String
    public var columns :[MigrationColumn]
    private func _columnString() -> String?
    {
        return columns.map {
            $0.toString()
        }.joined(separator :",")
    }
    public func toSQL() -> String
    {
        var result = "CREATE TABLE IF NOT EXISTS \(tableName)"
        if let columnString = self._columnString() where 0 < columnString.characters.count
        {
            result += " (\(columnString))"
        }
        return result
    }
}
public struct MigrationTypeDrop :MigrationTypeProtocol {
    public var tableName :String
    public func toSQL() -> String
    {
        return "DROP TABLE \(tableName)"
    }
}
public struct MigrationTypeAlterRename :MigrationTypeProtocol
{
    public var tableName :String
    var newTableName :String
    public func toSQL() -> String
    {
        return "ALTER TABLE \(tableName) RENAME \(newTableName)"
    }
}
public struct MigrationTypeAlterAdd :MigrationTypeProtocol
{
    public var tableName :String
    var column :MigrationColumn
    public func toSQL() -> String
    {
        return "ALTER TABLE \(tableName) ADD \(column.toString())"
    }
}
public struct MigrationTypeAlterChange :MigrationTypeProtocol
{
    public var tableName :String
    var columnName :String
    var column :MigrationColumn
    public func toSQL() -> String
    {
        return "ALTER TABLE \(tableName) CHANGE \(columnName) \(column.toString())"
    }
}
public struct MigrationTypeAlterModify :MigrationTypeProtocol
{
    public var tableName :String
    var columnName :String
    var column :MigrationColumn
    public func toSQL() -> String
    {
        return "ALTER TABLE \(tableName) MODIFY \(column.toString())"
    }
}
public struct MigrationItem
{
    var migrationVersion :Int
    var migrationType :MigrationTypeProtocol
}
