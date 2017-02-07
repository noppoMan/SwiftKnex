//
//  Schema.swift
//  SwiftKnex
//
//  Created by Yuki Takei on 2017/01/14.
//
//

import Foundation

public enum SchemaError: Error {
    case primaryKeyShouldBeOnlyOne
}

public struct Schema {
    
    public enum Charset {
        case utf8
    }
    
    public enum IndexType {
        case index
        case unique
    }
    
    public class Field {
        let name: String
        
        let type: FieldType
        
        var isPrimaryKey = false
        
        var isAutoIncrement = false
        
        var isUnsigned = false
        
        var charset: Charset = .utf8
        
        var index: IndexType?
        
        var isNotNullable = false
        
        var beforeColumn: String?
        
        var defaultValue: Any?
        
        public init(name: String, type: FieldType) {
            self.name = name
            self.type = type
        }
        
        public func `default`(to value: Any) -> Field  {
            self.defaultValue = value
            return self
        }
        
        public func after(for name: String) -> Field  {
            self.beforeColumn = name
            return self
        }
        
        public func asPrimaryKey() -> Field {
            self.isPrimaryKey = true
            return self
        }
        
        public func asAutoIncrement() -> Field {
            self.isAutoIncrement = true
            return self
        }
        
        public func asNotNullable() -> Field {
            self.isNotNullable = true
            return self
        }
        
        public func asUnsigned() -> Field {
            self.isUnsigned = true
            return self
        }
        
        public func charset(_ char: Charset) -> Field {
            self.charset = char
            return self
        }
        
        public func asUnique() -> Field {
            self.index = .unique
            return  self
        }
        
        public func asIndex() -> Field {
            self.index = .index
            return  self
        }
    }
    
    public enum MYSQLEngine: String {
        case innodb = "InnoDB"
    }
    
    public enum SchemaStatement {
        case create
        case drop
        case alter
    }
    
    public struct Index {
        let name: String
        let columns: [String]
        let isUnique: Bool
    }
    
    public struct TimeStampFields {
        let forCreated: Schema.Field
        
        let forUpdated: Schema.Field
        
        public init(forCreated: String = "created_at", forUpdated: String = "updated_at"){
            self.forCreated = Schema.datetime(forCreated)
            self.forUpdated = Schema.datetime(forUpdated)
        }
    }
    
    final class Buiulder {
        
        let fields: [Schema.Field]
        
        var charset: Charset?
        
        var timezone: String = "Local"
        
        var timestamp: TimeStampFields?
        
        var table: String
        
        var engine: MYSQLEngine = .innodb
        
        var indexes = [Index]()
        
        init(_ table: String, _ fields: [Schema.Field]) {
            self.table = table
            self.fields = fields
        }
        
        func index(name: String? = nil, columns: [String], unique: Bool = false){
            indexes.append(
                Index(
                    name: name ?? "\(table)_\(columns.joined(separator: "_and_"))_\(unique ? "unique":"index")",
                    columns: columns,
                    isUnique: unique
                )
            )
        }
        
        func engine(_ engine: MYSQLEngine){
            self.engine = engine
        }
        
        func charset(_ char: Charset) {
            self.charset = char
        }
        
        func hasTimestamps(_ timestampFields: TimeStampFields){
            self.timestamp = timestampFields
        }
        
        func buildFields() -> [String] {
            var schemaDefiniations = [String]()
            
            var fields = self.fields
            if let timestamp = self.timestamp {
                fields += [timestamp.forCreated, timestamp.forUpdated]
            }
            
            for f in fields {
                var str = ""
                str += pack(key: f.name)
                str += " \(f.type.build())"
                if f.isUnsigned {
                    str += " UNSIGNED"
                }
                
                if f.isNotNullable || f.isPrimaryKey {
                    str += " NOT NULL"
                } else {
                    if let defaultVal = f.defaultValue {
                        str += " DEFAULT \(defaultVal)"
                    } else {
                        str += " DEFAULT NULL"
                    }
                }
                
                if f.isAutoIncrement {
                    str += " AUTO_INCREMENT"
                }
                
                schemaDefiniations.append(str)
            }
            
            return schemaDefiniations
        }
        
        func buildIndexes() -> [String] {
            var indexKeys = [String]()
            for f in fields {
                if let index = f.index {
                    let indexStr: String
                    switch index {
                    case .index:
                        indexStr = "KEY `\(table)_\(f.name)_index`(\(pack(key: f.name)))"
                    case .unique:
                        indexStr = "UNIQUE KEY `\(table)_\(f.name)_unique`(\(pack(key: f.name)))"
                    }
                    indexKeys.append(indexStr)
                }
            }
            
            for index in indexes {
                var key = "KEY `\(index.name)`(\(index.columns.map({ pack(key: $0) }).joined(separator: ", ")))"
                if index.isUnique {
                    key = "UNIQUE \(key)"
                }
                indexKeys.append(key)
            }
            
            return indexKeys
        }
        
        func buildPrimaryKey() throws -> String? {
            var primaryKey: String?
            for f in fields {
                if f.isPrimaryKey {
                    if primaryKey != nil {
                        throw SchemaError.primaryKeyShouldBeOnlyOne
                    }
                    primaryKey = "PRIMARY KEY(\(pack(key: f.name)))"
                }
            }
            return primaryKey
        }
    }
}


extension Schema {
    public enum FieldType {
        case integer(length: Int)
        case bigInteger(length: Int)
        case string(length: Int)
        case text(length: Int?)
        case mediumText(length: Int?)
        case float(digits: Int?, decimalDigits: Int?)
        case double(digits: Int?, decimalDigits: Int?)
        case boolean
        case datetime
        case json
        
        func build() -> Swift.String {
            switch self {
            case .integer(length: let length):
                return "INT(\(length))"
                
            case .bigInteger(length: let length):
                return "BIGINT(\(length))"
                
            case .string(length: let length):
                return "VARCHAR(\(length))"
                
            case .text(length: let length):
                if let length = length {
                    return "TEXT(\(length))"
                } else {
                    return "TEXT"
                }
                
            case .mediumText(length: let length):
                if let length = length {
                    return "MEDIUMTEXT(\(length))"
                } else {
                    return "MEDIUMTEXT"
                }
                
            case .float(digits: let _digits, decimalDigits: let _decimalDigits):
                if let digits = _digits, let decimalDigits = _decimalDigits {
                    return "FLOAT(\(digits), \(decimalDigits))"
                } else {
                    return "FLOAT"
                }
                
            case .double(digits: let _digits, decimalDigits: let _decimalDigits):
                if let digits = _digits, let decimalDigits = _decimalDigits {
                    return "Double(\(digits), \(decimalDigits))"
                } else {
                    return "Double"
                }
                
            case .boolean:
                return "TINYINT(1)"
                
            case .datetime:
                return "DATETIME"
                
            case .json:
                return "JSON"
            }
        }
    }
    
    public static func integer(_ name: String, length: Int = 11) -> Field {
        return Field(name: name, type: .integer(length: length))
    }
    
    public static func bigInteger(_ name: String, length: Int = 20) -> Field {
        return Field(name: name, type: .bigInteger(length: length))
    }
    
    public static func string(_ name: String, length: Int = 255) -> Field {
        return Field(name: name, type: .string(length: length))
    }
    
    public static func text(_ name: String, length: Int? = nil) -> Field {
        return Field(name: name, type: .text(length: length))
    }
    
    public static func mediumText(_ name: String, length: Int? = nil) -> Field {
        return Field(name: name, type: .mediumText(length: length))
    }
    
    public static func float(_ name: String, digits: Int? = nil, decimalDigits: Int? = nil) -> Field {
        return Field(name: name, type: .float(digits: digits, decimalDigits: decimalDigits))
    }
    
    public static func double(_ name: String, digits: Int? = nil, decimalDigits: Int? = nil) -> Field {
        return Field(name: name, type: .double(digits: digits, decimalDigits: decimalDigits))
    }
    
    public static func boolean(_ name: String) -> Field {
        return Field(name: name, type: .boolean)
    }
    
    public static func datetime(_ name: String) -> Field {
        return Field(name: name, type: .datetime)
    }
    
    public static func json(_ name: String) -> Field {
        return Field(name: name, type: .json)
    }
}
