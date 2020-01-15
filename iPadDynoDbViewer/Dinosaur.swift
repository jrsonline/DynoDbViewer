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
import DynoTableDataView

struct Dinosaur : Codable, Identifiable {
    let id: String
    let name: String
    let colours: [String]
    let teeth: Int
}

extension Dinosaur: DynoTableContent {   
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

let testDinos = [Dinosaur(id: "1", name: "Tyrannosaur", colours: ["red"], teeth: 25),Dinosaur(id: "2", name: "Velociraptor", colours: ["brown","green"], teeth: 250) ]

