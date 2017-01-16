//
//  MigrationTests.swift
//  SwiftKnex
//
//  Created by Yuki Takei on 2017/01/17.
//
//

import XCTest
@testable import SwiftKnex
import Foundation

class Migration_20170101000000_CreateEmployee: Migratable {
    var name: String {
        return String(validatingUTF8: object_getClassName(self))!
    }
    
    func up(_ migrator: Migrator) throws {
        let create = Create(
            table: "employees",
            fields: [
                Schema.Field(name: "id", type: Schema.Types.Integer()).asPrimaryKey().asAutoIncrement(),
                Schema.Field(name: "name", type: Schema.Types.String()).asIndex().asNotNullable(),
                Schema.Field(name: "company_id", type: Schema.Types.Integer()).asIndex().asNotNullable()
            ])
            .hasTimestamps()

        try migrator.run(create)
    }
    
    func down(_ migrator: Migrator) throws {
        try migrator.run(Drop(table: "employees"))
    }
}

class Migration_20170102000000_CreateCompany: Migratable {
    var name: String {
        return String(validatingUTF8: object_getClassName(self))!
    }
    
    func up(_ migrator: Migrator) throws {
        let create = Create(
            table: "companies",
            fields: [
                Schema.Field(name: "id", type: Schema.Types.Integer()).asPrimaryKey().asAutoIncrement(),
                Schema.Field(name: "name", type: Schema.Types.String()).asNotNullable()
            ])
            .hasTimestamps()
        
        try migrator.run(create)
    }
    
    func down(_ migrator: Migrator) throws {
        try migrator.run(Drop(table: "companies"))
    }
}


class MigrationTests: XCTestCase {
    
    static var allTests : [(String, (MigrationTests) -> () throws -> Void)] {
        return [
            ("testMigrateLatest", testMigrateLatest),
            ("testMigrateRollback", testMigrateRollback)
        ]
    }
    
    var con: KnexConnection!
    
    override func setUp() {
        con = try! KnexConnection(config: basicKnexConfig())
        cleanupTables()
    }
    
    override func tearDown() {
        cleanupTables()
        try! con!.close()
    }
    
    func cleanupTables() {
        ["knex_migrations", "employees", "companies"].forEach {
            do {
                try con.knex().execRaw(sql: "drop table \($0)")
            } catch {
                // None
            }
        }
    }
    
    func testMigrateLatest() {
        let knexMigrations: [Migratable] = [
            Migration_20170101000000_CreateEmployee(),
            Migration_20170102000000_CreateCompany()
        ]
        
        let runner = try! MigrateRunner(config: basicKnexConfig(), knexMigrations: knexMigrations)
        try! runner.up()
        
        let rows = try! con.knex().table("knex_migrations").fetch()
        XCTAssertEqual(rows!.count, 2)
        XCTAssertEqual(rows!.first!["batch"] as! Int, 1)
        
        let result = try! con.knex().execRaw(sql: "show tables")
        
        let count = result.asResultSet()!.filter({
            let t = $0["Tables_in_swift_knex_test"] as! String
            return t == "companies" || t == "employees"
        }).count
        XCTAssertEqual(count, 2)
    }
    
    func testMigrateRollback() {
        let runner1 = try! MigrateRunner(config: basicKnexConfig(), knexMigrations: [Migration_20170101000000_CreateEmployee()])
        try! runner1.up()
        XCTAssertEqual(1, try! con.knex().table("knex_migrations").fetch()!.count)
        
        let runner2 = try! MigrateRunner(config: basicKnexConfig(), knexMigrations: [Migration_20170101000000_CreateEmployee(), Migration_20170102000000_CreateCompany()])
        try! runner2.up()
        XCTAssertEqual(2, try! con.knex().table("knex_migrations").fetch()!.count)
        
        try! runner2.down()
        XCTAssertEqual(1, try! con.knex().table("knex_migrations").fetch()!.count)
        
        try! runner2.down()
        XCTAssertNil(try! con.knex().table("knex_migrations").fetch())
    }
    
}

