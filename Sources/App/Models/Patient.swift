//
//  Patient.swift
//  App
//
//  Created by JHartl on 5/3/18.
//

typealias ByteData = Array<UInt8>

import Foundation
import Vapor
import FluentProvider

final class Patient: Model {
    var storage = Storage()
    var patientID: String
    var providerID: String
    var content: ByteData
    
    init(patientID: String, providerID: String, content: ByteData) {
        self.patientID = patientID
        self.providerID = providerID
        self.content = content
    }

    func makeRow() throws -> Row {
        var row = Row()
        try row.set("patientID", patientID)
        try row.set("providerID", providerID)
        try row.set("content", StructuredData.bytes(content))
        return row
    }
    
    init(row: Row) throws {
        self.patientID = try row.get("patientID")
        self.providerID = try row.get("providerID")
        self.content = row["content"]?.bytes ?? []
    }
}

extension Patient: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string("patientID")
            builder.string("providerID")
            builder.bytes("content") //Not sure this is correct.
        }
    }
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

//extension Patient: NodeRepresentable {
//    func makeNode(in context: Context?) throws -> Node {
//        var node = Node(context)
//        try node.set("id", id)
//        try node.set("patientID", patientID)
//        try node.set("providerID", providerID)
//        try node.set("content", content)
//        return node
//    }
//}
