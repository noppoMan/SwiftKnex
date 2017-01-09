//
//  Connection+parser.swift
//  SwiftKnex
//
//  Created by Yuki Takei on 2017/01/10.
//
//

import Foundation

public protocol ConnectionType {
    var url: URL { get }
    var user: String { get }
    var password: String? { get }
    var database: String? { get }
    var isClosed: Bool { get }
}
