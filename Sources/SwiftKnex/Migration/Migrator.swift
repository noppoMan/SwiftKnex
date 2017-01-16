//
//  Migrator.swift
//  SwiftKnex
//
//  Created by Yuki Takei on 2017/01/15.
//
//

import Foundation

extension Date {
    static func from(string: String?, format: String = "yyyy-MM-dd HH:mm:ss") -> Date? {
        guard let string = string else {
            return nil
        }
        let formatter: DateFormatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.date(from: string)
    }
    
    func toString(format: String = "yyyy-MM-dd HH:mm:ss") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
}

public enum MigrationError: Error {
    case invalidMigrationName(String)
    case timestampFormatShouldBe(String)
    case migrationIsCorrupt
}

public protocol Migratable: class {
    var name: String { get }
    func up(_ migrator: Migrator) throws
    func down(_ migrator: Migrator) throws
}

func validateMigration(name fullName: String) throws -> String {
    let s = fullName.components(separatedBy: ".")
    let name = s[s.count-1]
    
    let segments = name.components(separatedBy: "_")
    if segments.count != 3 {
        throw MigrationError.invalidMigrationName(name)
    }
    
    if segments[0] != "Migration" {
        throw MigrationError.invalidMigrationName(name)
    }
    
    let ts = segments[1]
    if ts.characters.count != 14 {
        throw MigrationError.timestampFormatShouldBe("yyyyMMddHHmmss")
    }
    
    let year = ts.substring(to: ts.index(ts.startIndex, offsetBy: 4))
    let month = ts[ts.index(ts.startIndex, offsetBy: 4)..<ts.index(ts.startIndex, offsetBy: 6)]
    let day = ts[ts.index(ts.startIndex, offsetBy: 6)..<ts.index(ts.startIndex, offsetBy: 8)]
    let hour = ts[ts.index(ts.startIndex, offsetBy: 8)..<ts.index(ts.startIndex, offsetBy:10)]
    let minute = ts[ts.index(ts.startIndex, offsetBy: 10)..<ts.index(ts.startIndex, offsetBy:12)]
    let second = ts[ts.index(ts.startIndex, offsetBy: 12)..<ts.index(ts.startIndex, offsetBy:14)]
    
    if Date.from(string: "\(year)-\(month)-\(day) \(hour):\(minute):\(second)") == nil {
        throw MigrationError.timestampFormatShouldBe("yyyyMMddHHmmss")
    }
    
    return name
}

struct MigrationSchema {
    let id: Int
    let name: String
    let batch: Int
    let migrationTime: Date
    
    init(dictionary: [String: Any]){
        self.id = dictionary["id"] as! Int
        self.name = try! validateMigration(name: dictionary["name"] as! String)
        self.batch = dictionary["batch"] as! Int
        self.migrationTime = dictionary["migration_time"] as! Date
    }
}

extension Collection where Self.Iterator.Element == MigrationSchema {
    func lastBatch() -> Int {
        return self.map({ $0.batch }).max() ?? 0
    }
}

public class MigrateRunner {
    
    let knexMigrations: [Migratable]
    
    let con: KnexConnection
    
    public init(config: KnexConfig, knexMigrations: [Migratable]) throws {
        con = try KnexConnection(config: config)
        self.knexMigrations = knexMigrations
        
        try createMigrationTableIfNotExists()
    }
    
    public func up() throws {
        try con.knex().transaciton { trx in
            var recentMigrated = [String]()
            let migrationsPeformed = try fetchMigrations(trx: trx)
            
            // At the first time
            if migrationsPeformed.isEmpty {
                for m in knexMigrations {
                    let name = try validateMigration(name: m.name)
                    try m.up(Migrator(trx: trx))
                    recentMigrated.append(name)
                }
                try markLatest(batch: 1, migrationNames: recentMigrated, trx: trx)
                return
            }
            
            // After second times
            for m in knexMigrations {
                let name = try validateMigration(name: m.name)
                if migrationsPeformed.contains(where: { $0.name == name }) {
                    continue
                }
                
                try m.up(Migrator(trx: trx))
                recentMigrated.append(name)
            }
            
            try markLatest(batch: migrationsPeformed.lastBatch()+1, migrationNames: recentMigrated, trx: trx)
        }
    }
    
    public func down() throws {
        try con.knex().transaciton { trx in
            let migrationsPeformed = try fetchMigrations(trx: trx)
            if migrationsPeformed.isEmpty {
                return
            }
            
            let lastBatch = migrationsPeformed.lastBatch()
            guard let results = try con.knex()
                .table(con.config.migration.table)
                .where("batch" == lastBatch)
                .fetch() else {
                return
            }
            
            let peformedAtLastBatches = results.map({ MigrationSchema(dictionary: $0) })
            
            let rollbackMigrations = try knexMigrations.filter({ m in
                let name = try validateMigration(name: m.name)
                return peformedAtLastBatches.contains(where: { $0.name == name })
            })
            
            for m in rollbackMigrations {
                try m.down(Migrator(trx: trx))
            }
            
            let deleteIDs = peformedAtLastBatches.map({ $0.id })
            _ = try con.knex()
                .table(con.config.migration.table)
                .where(.in(field: "id", values: deleteIDs))
                .delete(trx: trx)
        }
    }
    
    fileprivate func fetchMigrations(trx: Connection) throws -> [MigrationSchema] {
        guard let results = try con.knex().table(con.config.migration.table).fetch(trx: trx) else {
            return []
        }
        return results.map({ MigrationSchema(dictionary: $0) })
    }
    
    fileprivate func markLatest(batch: Int, migrationNames: [String], trx: Connection) throws {
        let now = Date()
        for name in migrationNames {
            _ = try con.knex().insert(
                into: con.config.migration.table,
                values: [
                    "name": name,
                    "batch": batch,
                    "migration_time": "\(now)"
                ],
                trx: trx
            )
        }
    }
    
    fileprivate func createMigrationTableIfNotExists() throws {
        let result = try con.knex().execRaw(sql: "SHOW TABLES LIKE '\(con.config.migration.table)'")
        
        if !result.isNoRecord {
            return
        }
        
        let createDDL = Create(table: con.config.migration.table, fields: [
            Schema.Field(name: "id", type: .int(length: 10)).asPrimaryKey().asAutoIncrement(),
            Schema.Field(name: "name", type: .string(length: nil)),
            Schema.Field(name: "batch", type: .int(length: 11)),
            Schema.Field(name: "migration_time", type: .datetime).asNotNullable()
        ])
        
        _ = try con.knex().execRaw(sql: createDDL.toDDL())
    }
}

public class Migrator {
    
    let trx: Connection
    
    init(trx: Connection){
        self.trx = trx
    }
    
    public func run(_ builder: DDLBuildable) throws {
        _ = try trx.query(builder.toDDL())
    }
}

extension Migrator {
    
    public static func run(config: KnexConfig, arguments: [String], knexMigrations: [Migratable]) throws {
        if arguments.count < 2 {
            fatalError("Command Fot found")
        }
        
        let runner = try MigrateRunner(config: config, knexMigrations: knexMigrations)
        
        switch arguments[1] {
        case "migrate:latest":
            try runner.up()
        case "migrate:rollback":
            try runner.down()
        default:
            fatalError("Command Fot found")
        }
    }
}
