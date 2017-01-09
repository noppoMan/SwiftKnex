//
//  RowDataParsable.swift
//  SwiftKnex
//
//  Created by Yuki Takei on 2017/01/12.
//
//

protocol RowDataParsable {
    var hasMoreResults: Bool { get set }
    var columns: [Field] { get }
    func parse(bytes: [UInt8]) throws -> Row?
    init(columns: [Field])
}
