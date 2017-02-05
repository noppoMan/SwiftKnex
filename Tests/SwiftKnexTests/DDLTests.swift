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
            Schema.Field(name: "id", type: Schema.Types.Integer()).asPrimaryKey().asAutoIncrement(),
            Schema.Field(name: "f1", type: Schema.Types.String()).asUnique().asNotNullable(),
            Schema.Field(name: "f2", type: Schema.Types.Text()),
            Schema.Field(name: "f3", type: Schema.Types.MediumText()),
            Schema.Field(name: "f4", type: Schema.Types.BigInteger()).asUnsigned().default(to: 0),
            Schema.Field(name: "f5", type: Schema.Types.DateTime()).asIndex(),
            Schema.Field(name: "f6", type: Schema.Types.Float()),
            Schema.Field(name: "f7", type: Schema.Types.Double()),
            Schema.Field(name: "f8", type: Schema.Types.Boolean()).asIndex()
        ])
        .hasTimestamps()
        
        try! con.knex().execRaw(sql: create.toDDL())
    }
}

