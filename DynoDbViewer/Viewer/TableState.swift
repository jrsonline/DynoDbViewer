//
//  TableState.swift
//  DynoDbViewer
//
//  Created by RedPanda on 15-Nov-19.
//  Copyright © 2019 strictlyswift. All rights reserved.
//

import Foundation
import SwiftUI


struct TableState<Frame:TableDataFrame> {
    var sortColumn: Frame.ColumnId? = nil
    var order: TableSortOrder = .none
    var columnPositions: [Frame.ColumnId:Int] = [:]
    var originalColumnPositions: [Frame.ColumnId:Int] = [:]

    mutating func loaded(frame: Frame) {
        self.columnPositions = Dictionary(uniqueKeysWithValues:zip(frame.columns, 0...))
        self.originalColumnPositions = self.columnPositions
    }

    enum TableSortOrder {
        case none
        case ascending
        case descending
        
        func sortOrderGraphic() -> String {
            switch self {
            case .none: return ""
            case .ascending: return "▼"
            case .descending: return "▲"
            }
        }
        
        func next() -> TableSortOrder {
            switch self {
            case .none: return .descending
            case .descending: return .ascending
            case .ascending: return .none
            }
        }
    }
    
    mutating func nextFor(newId: Frame.ColumnId) {
        if newId == sortColumn {
            self.order = self.order.next()
        } else {
            self.sortColumn = newId
            self.order = .descending
        }
    }
    
    func sorting(_ array: [Frame.Content]) -> [Frame.Content] {
        guard self.order != .none else { return array }
        
        let sortOrder = (self.order == .descending) ? (Frame.Content.sorter(for: self.sortColumn)) : ({ (a,b) in !Frame.Content.sorter(for: self.sortColumn)(a,b) })
        return array.sorted(by: sortOrder)
    }
    
    mutating func hideColumn(id: Frame.ColumnId) {
        guard self.visibleColumnCount > 1 else { return }
        self.columnPositions[id] = nil
    }
    
    var visibleColumnCount : Int  { get { self.columnPositions.values.count} }
    
    mutating func unhideColumns() {
        self.columnPositions = self.originalColumnPositions
    }
    
    func viewForSort() -> some View {
        HStack {
            Spacer()
            Text(order.sortOrderGraphic())
        }
        .padding(.trailing, 12)
    }
}



/*
class TableStateInfo<M:TableDataSource> {
    var sortOrders: [M.ColumnId:TableSortOrder]
    var columnPosition: [M.ColumnId:Int?]

    init() {
        self.sortOrders = Dictionary(uniqueKeysWithValues: M.columnIds.map { ($0,.none) })
        self.columnPosition = Dictionary(uniqueKeysWithValues:zip(M.columnIds, 0...))
    }
    
    func sortView(id: M.ColumnId) -> AnyView {
        return HStack {
            Spacer()
            Text(self.sortOrders[id]?.sortOrderGraphic() ?? "")
        }
        .padding(.trailing, 6)
        .asAnyView()
        
    }

    
    func setSingleSortColumn(id: M.ColumnId) {
        let currentSort = self.sortOrders[id]!
        // reset everything
        self.sortOrders = Dictionary(uniqueKeysWithValues: M.columnIds.map { ($0,.none) })
        self.sortOrders[id] = currentSort.next()
    }
}
*/

