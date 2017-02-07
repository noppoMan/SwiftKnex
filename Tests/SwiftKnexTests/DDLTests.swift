//
//  DDLTests.swift
//  SwiftKnex
//
//  Created by Yuki Takei on 2017/01/17.
//
//

import XCTest
@testable import SwiftKnex
import Foundation

class DDLTests: XCTestCase {
    
    static var allTests : [(String, (DDLTests) -> () throws -> Void)] {
        return [
            ("testCreate", testCreate)
        ]
    }
    
    var con: KnexConnection!
    
    override func setUp() {
        con = try! KnexConnection(config: basicKnexConfig())
        dropTable()
    }
    
    override func tearDown() {
        dropTable()
        try! con.close()
    }
    
    func dropTable(){
        try! con.knex().transaction { trx in
            do {
                _ = try con.knex().execRaw(trx: trx, sql: Drop(table: "test_users").toDDL())
            } catch {
                
            }
        }
    }
    
    func testCreate(){
        let create = Create(table: "test_users", fields: [
            Schema.integer("id").asPrimaryKey().asAutoIncrement(),
            Schema.string("f1").asUnique().asNotNullable(),
            Schema.text("f2"),
            Schema.mediumText("f3"),
            Schema.bigInteger("f4").asUnsigned().default(to: 0),
            Schema.datetime("f5"),
            Schema.float("f6"),
            Schema.double("f7"),
            Schema.boolean("f8").asIndex(),
            Schema.json("f9")
        ])
        .hasTimestamps()
        
        _ = try! con.knex().execRaw(sql: create.toDDL())
    }
}

