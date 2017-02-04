//
//  JSONDataTypeTests.swift
//  SwiftKnex
//
//  Created by Yuki Takei on 2017/02/01.
//
//

import XCTest
@testable import SwiftKnex
import Foundation

class JSONDataTypeTests: XCTestCase {
    
    static var allTests : [(String, (JSONDataTypeTests) -> () throws -> Void)] {
        return [
            ("testSelect", testSelect)
        ]
    }
    
    var con: KnexConnection!
    
    override func setUp() {
        con = try! KnexConnection(config: basicKnexConfig())
        dropTable()
        
        let jsonTable = Create(table: "json_table", fields: [
            Schema.Field(name: "id", type: Schema.Types.Integer()).asPrimaryKey().asAutoIncrement(),
            Schema.Field(name: "body", type: Schema.Types.JSON())
        ])
        
        try! con.knex().transaction { trx in
            _ = try! con.knex().execRaw(trx: trx, sql: jsonTable.toDDL())
            let json: [String: Any] = [
                "name": "Luke",
                "job": "Jedai",
                "age": 20,
                "attrs": [
                    "hair-color": "blonds",
                    "right-saver-color": "green"
                ]
            ]
            _ = try! con.knex().insert(into: "json_table", values: ["body": json], trx: trx)
            

            let json2: [String: Any] = [
                "name": "Darth Vader",
                "job": "Sith",
                "age": 50,
                "attrs": [
                    "hair-style": "skin head",
                    "right-saver-color": "red"
                ]
            ]
            _ = try! con.knex().insert(into: "json_table", values: ["body": json2], trx: trx)
        }
    }
    
    override func tearDown() {
        dropTable()
        try! con!.close()
    }
    
    func dropTable(){
        do {
            _ = try con.knex().execRaw(sql: Drop(table: "json_table").toDDL())
        } catch {
            // Skip
        }
    }
    
    func testSelect(){
        var rows: ResultSet?
        rows = try! con.knex()
            .select(raw("JSON_UNQUOTE(JSON_EXTRACT(body, '$.name'))").as("name"))
            .table("json_table")
            .fetch()
        
        XCTAssertEqual(rows?[0]["name"] as? String, "Luke")
        XCTAssertEqual(rows?[1]["name"] as? String, "Darth Vader")
        
        rows = try! con.knex()
            .select(raw("JSON_UNQUOTE(JSON_EXTRACT(body, '$.name'))").as("name"))
            .where(.raw("JSON_UNQUOTE(JSON_EXTRACT(body,'$.job')) = ?", ["Jedai"]))
            .table("json_table")
            .fetch()
        
        XCTAssertEqual(rows?[0]["name"] as? String, "Luke")
    }
    
    func testUpdate() {
        let res = try! con.knex()
            .table("json_table")
            .where(.raw("JSON_UNQUOTE(JSON_EXTRACT(body,'$.name')) = ?", ["Luke"]))
            .update(query: "body = JSON_REPLACE(body, '$.name', ?)", params: ["Obi Wan"])
        
        XCTAssertEqual(res!.affectedRows, 1)
    }
}
