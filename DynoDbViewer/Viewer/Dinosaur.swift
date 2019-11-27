//
//  Dinosaur.swift
//  DynoDbViewer
//
//  Created by RedPanda on 15-Nov-19.
//  Copyright © 2019 strictlyswift. All rights reserved.
//

import Foundation
import SwiftUI
import Combine
import Dyno

struct Dinosaur : Codable, Identifiable {
    let id: String
    let name: String
    let colours: [String]
    let teeth: Int
}

extension Dinosaur: TableDataContent {
    enum Column: CaseIterable {
        case id, name, colours, teeth
    }
    
    func display(for id: Column) -> AnyView {
        switch id {
        case .id: return Text(self.id).asAnyView()
        case .name: return Text(self.name).asAnyView()
        case .colours: return Text("\(self.colours.joined(separator: ","))").asAnyView()
        case .teeth: return Text("\(self.teeth)").asAnyView()
        }
    }
    
    static func header(for id: Column) -> AnyView {
        switch id {
        case .id : return Text("Id #").asAnyView()
        case .name: return Text("Name").asAnyView()
        case .colours: return Text("Colours").asAnyView()
        case .teeth: return Text("# Teeth").asAnyView()
        }
    }
    
    static func sorter(for id: Dinosaur.Column?) -> ((Dinosaur,Dinosaur) -> Bool) {
        guard let id = id else { return {(_,_) in true} }
        switch id {
        case .id: return { (a,b) in (a.id < b.id) }
        case .name: return { (a,b) in (a.name < b.name) }
        case .colours: return { (a,b) in (a.colours.joined() < b.colours.joined()) }
        case .teeth: return { (a,b) in (a.teeth < b.teeth) }
        }
    }
    
}


struct DinosaurDataTable : TableDataFrame {
    static let 🦕 : Dyno = Dyno(options: DynoOptions(log: true))!
    
    var columns : [Dinosaur.Column] { get { Dinosaur.Column.allCases }}
    var content : [Dinosaur] = []
    
    static func load(_ table: String? = nil) -> AnyPublisher<Self,Error> {
        🦕.scan(table: "Dinosaurs",
                type: Dinosaur.self)
          .map { DinosaurDataTable(content:$0.result) }
          .eraseToAnyPublisher()
    }
    


}

let testDinos = [Dinosaur(id: "1", name: "Tyrannosaur", colours: ["red"], teeth: 25),Dinosaur(id: "2", name: "Velociraptor", colours: ["brown","green"], teeth: 250) ]

/// Represents an arbitrary object retrieved from a DynamoDb database
struct DynoObject : Identifiable {
    let data : [String: DynoAttributeValue]
    let id: String = UUID().uuidString
    
    init(data: [String: DynoAttributeValue]) {
        self.data = data
    }
    
//    static var columnIds: [String] = []// ["id","teeth","name","colours"]

    
    func content(for id: String) -> AnyView {
//        NSLog("id = \(id), attribute = \(Self.attributeToString(data[id] ?? .S("nil")))")
        guard let attribute = data[id] else { return EmptyView().asAnyView() }
        return Text(Self.attributeToString(attribute)).asAnyView()
    }
    
    static private func attributeToString(_ attr: DynoAttributeValue) -> String {
        switch attr {
        case .B(_):
            return "<binary data>"
        case .BOOL(let isTrue):
            return  isTrue ? "Yes" : "No"
        case .BS(_):
            return "<binary set>"
        case .M(let mmap):
            return mmap.map { "\($0.0)=\(Self.attributeToString($0.1))"}.joined(separator: ",")
        case .S(let string):
            return string
        case .N(let number):
            return number
        case .NS(let listOfNumbers):
            return listOfNumbers.joined(separator: ",")
        case .NULL(_):
            return "NULL"
        case .SS(let listOfStrings):
            return listOfStrings.joined(separator: ",")
        case .L(let list):
            return list.map { Self.attributeToString($0) }.joined(separator: ",")
        }
    }
    
    static func header(for id: String) -> AnyView {
        return Text(id).asAnyView()

    }
    
    static func sorter(for id: String?) -> ((DynoObject, DynoObject) -> Bool) {
        guard let id = id else { return {(_,_) in true} }
        
        // everything except numbers, we sort as text (including number sets, because honestly who knows what the right answer is here
        return { (a,b) in
            guard let a_attr = a.data[id], let b_attr = b.data[id] else { return true }
            switch (a_attr, b_attr) {
            case let (.N(a_n), .N(b_n)):
                guard let aAsNumber = Double(a_n), let bAsNumber = Double(b_n) else { return true }
                return aAsNumber < bAsNumber
            default:
                return self.attributeToString(a_attr) < self.attributeToString(b_attr)
            }
        }
    }
    
    static let 🦕 : Dyno = Dyno(options: DynoOptions(log: true))!
    
    static func load(_ table: String?) -> AnyPublisher<[DynoObject],Error> {
        guard let dataTable = table else { fatalError("No data table set up for load") }
        
        return 🦕.scanToTypeDescriptors(table: dataTable)
            .map { (d:DynoResult<[String:DynoAttributeValue]>) in
                d.result.compactMap { DynoObject(data:$0) }
        }
        .eraseToAnyPublisher()
    }
    
    typealias ColumnId = String
}

