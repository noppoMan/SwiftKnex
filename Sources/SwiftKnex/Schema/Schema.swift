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

public protocol FieldType {
    func build() -> Swift.String
}

public protocol BasicFieldType: FieldType {
    var length: Int { get }
    var fieldType: Swift.String { get }
}

extension BasicFieldType {
    public func build() -> Swift.String {
        return "\(fieldType)(\(length))"
    }
}

public struct Schema {
    
    public struct Types {
        public struct Integer: BasicFieldType {
            public let length: Int
            
            public var fieldType: Swift.String {
                return "INT"
            }
            
            public init(length: Int = 11){
                self.length = length
            }
        }
        
        public struct BigInteger: BasicFieldType {
            public let length: Int
            
            public var fieldType: Swift.String {
                return "BIGINT"
            }
            
            public init(length: Int = 20){
                self.length = length
            }
        }
        
        public struct String: BasicFieldType {
            public let length: Int
            
            public var fieldType: Swift.String {
                return "VARCHAR"
            }
            
            public init(length: Int = 255){
                self.length = length
            }
        }
        
        public struct Text: FieldType {
            public let length: Int?
            
            public init(length: Int? = nil){
                self.length = length
            }
            
            public func build() -> Swift.String {
                if let length = self.length {
                    return "TEXT(\(length))"
                } else {
                    return "TEXT"
                }
            }
        }
        
        public struct MediumText: FieldType {
            public let length: Int?
            
            public init(length: Int? = nil){
                self.length = length
            }
            
            public func build() -> Swift.String {
                if let length = self.length {
                    return "MEDIUMTEXT(\(length))"
                } else {
                    return "MEDIUMTEXT"
                }
            }
        }
        
        public struct Boolean: FieldType {
            public init(){}
            
            public func build() -> Swift.String {
                return "TINYINT(1)"
            }
        }
        
        public struct DateTime: FieldType {
            public init(){}
            
            public func build() -> Swift.String {
                return "DATETIME"
            }
        }
        
        public struct Float: FieldType {
            let digits: Int?
            let decimalDigits: Int?
            
            public init(digits: Int? = nil, decimalDigits: Int? = nil){
                self.digits = digits
                self.decimalDigits = digits
            }
            
            public func build() -> Swift.String {
                if let digits = self.digits, let decimalDigits = self.decimalDigits {
                    return "FLOAT(\(digits), \(decimalDigits))"
                } else {
                    return "FLOAT"
                }
            }
        }
        
        public struct Double: FieldType {
            let digits: Int?
            let decimalDigits: Int?
            
            public init(digits: Int? = nil, decimalDigits: Int? = nil){
                self.digits = digits
                self.decimalDigits = digits
            }
            
            public func build() -> Swift.String {
                if let digits = self.digits, let decimalDigits = self.decimalDigits {
                    return "Double(\(digits), \(decimalDigits))"
                } else {
                    return "Double"
                }
            }
        }
    }
    
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
        
        public func `default`(as value: Any) -> Field  {
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
        
        public func asUngisned() -> Field {
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
    
    public struct TimeStampField {
        let forCreated: String
        
        let forUpdated: String
        
        public init(forCreated: String = "created_at", forUpdated: String = "updated_at"){
            self.forCreated = forCreated
            self.forUpdated = forUpdated
        }
    }
    
    final class Buiulder {
        
        let fields: [Schema.Field]
        
        var charset: Charset?
        
        var timezone: String = "Local"
        
        var timestamp: TimeStampField?
        
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
        
        func hasTimestamps(_ timestampField: TimeStampField){
            self.timestamp = timestampField
        }
        
        func buildFields() -> [String] {
            var schemaDefiniations = [String]()
            
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
