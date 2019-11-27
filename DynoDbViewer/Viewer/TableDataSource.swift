//
//  TableDataSource.swift
//  DynoDbViewer
//
//  Created by RedPanda on 15-Nov-19.
//  Copyright © 2019 strictlyswift. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

/*
protocol TableDataSource : Hashable {
    associatedtype ColumnId : Hashable
    
    static var columnIds:[ColumnId] { get }
    func content(for id: ColumnId) -> AnyView
    static func header(for id: ColumnId) -> AnyView
    static func sorter(for id: ColumnId?) -> ((Self,Self) -> Bool)
    static func load(_ table: String?) -> AnyPublisher<[Self],Error>
}
*/

protocol TableDataContent: Hashable {
    associatedtype ColumnId : Hashable
    func display(for id: ColumnId) -> AnyView
    
    static func header(for id: ColumnId) -> AnyView
    static func sorter(for id: ColumnId?) -> ((Self,Self) -> Bool)
}

protocol TableDataFrame {
    associatedtype ColumnId
    associatedtype Content : TableDataContent where Content.ColumnId == ColumnId

    var columns: [ColumnId] { get }
    var content: [Content] { get }
    
    static func load(_ table: String?) -> AnyPublisher<Self,Error>
}


extension TableDataContent {
    func tabulate<F>(tableState: Binding<TableState<F>>,
                tableDataFrame: F) -> some View
        where F : TableDataFrame, F.Content == Self {
        return GeometryReader { geometry in
            HStack(alignment: .center, spacing: 0) {
                ForEach(tableDataFrame.columns, id:\.self) { i in
                    self.drawColumn(i: i, geometry: geometry, tableState: tableState)
                }
                Spacer()
            }
        }
    }

    private func drawColumn<F>(i: Self.ColumnId,
                            geometry: GeometryProxy,
                            tableState: Binding<TableState<F>>) -> some View
    where F : TableDataFrame, F.Content == Self {
        return Group {
            if tableState.wrappedValue.columnPositions[i] != nil {
                self.display(for: i).frame(width: geometry.size.width / CGFloat(tableState.wrappedValue.visibleColumnCount),
                                                  height: geometry.size.height, alignment: .center)
                    .border(Color.primary, width:1)
            }
        }
    }
}

extension TableDataFrame {
    private static func drawHeaderWithSorter(i: Self.ColumnId,
                                     geometry: GeometryProxy,
                                     tableState: Binding<TableState<Self>>) -> some View {
        let posn = tableState.wrappedValue.columnPositions[i]
        return Group {
            if posn != nil {
                ZStack {
                    Content.header(for: i).frame(width: geometry.size.width / CGFloat(tableState.wrappedValue.visibleColumnCount),
                                              height: HEADER_HEIGHT,
                                              alignment: .center)
                        .border(Color.primary, width:1)
                        .background(Color.blue)
                    
                    if tableState.wrappedValue.sortColumn == i {
                        tableState.wrappedValue.viewForSort()
                    }
                    
                    if posn! > 0 {
                        HStack {
                            Text("▸")
                                .frame(height: HEADER_HEIGHT, alignment: .center)
                                .background(Color.clear)
                                .gesture(DragGesture()
                                    .onChanged { value in print( value )}
                                    .onEnded { value in print("Ended at ",value)}
                                ).onHover { entering in
                                    #if os(macOS)
                                    if entering {
                                        NSCursor.resizeLeftRight.push()
                                        NSCursor.resizeLeftRight.set()
                                    } else {
                                        NSCursor.pop()
                                    }
                                    #endif
                                }
                            Spacer()
                        }.padding(.leading, 1)
                        
                    }
                    
                    if posn! < (tableState.wrappedValue.visibleColumnCount-1) {
                        HStack {
                                Spacer()
                                Text("◂")
                                    .frame(height: HEADER_HEIGHT, alignment: .center)
                                    .background(Color.clear)
                                    .gesture(DragGesture()
                                        .onChanged { value in print( value )}
                                        .onEnded { value in print("Ended at ",value)}
                                    ).onHover { entering in
                                        #if os(macOS)
                                        if entering {
                                            NSCursor.resizeLeftRight.push()
                                            NSCursor.resizeLeftRight.set()
                                        } else {
                                            NSCursor.pop()
                                        }
                                        #endif
                                    }
                            }.padding(.trailing, 1)
                    }
                }
                
            }
        }
    }
    
    func headers(tableState: Binding<TableState<Self>>,
                 dataLoader: TableDataLoader<Self>) -> some View {
        return GeometryReader { geometry in
            HStack(alignment: .center, spacing: 0) {
                ForEach(self.columns, id:\.self) { i in
                    Self.drawHeaderWithSorter(i: i, geometry: geometry, tableState: tableState)
                        .onTapGesture {
                            tableState.wrappedValue.nextFor(newId: i)
                    }.contextMenu {
                        Button(action: {
                            tableState.wrappedValue.hideColumn(id: i)
                        }) {
                            Text("Hide Column").disabled(tableState.wrappedValue.visibleColumnCount > 1)
                        }
                        Button(action: {
                        }) {
                            Text("Fit Width")
                        }
                        VStack {
                            Divider()
                        }
                        Button(action: {
                            tableState.wrappedValue.unhideColumns()
                        }) {
                            Text("Unhide All")
                        }
                        Button(action: {
                            dataLoader.load(forState: tableState)
                        }) {
                            Text("Refresh")
                        }
                    }//modifier(HeaderMenu(column: i, tableState: tableState, dataLoader: dataLoader))  --> this doesn't work, I think a SwiftUI bug
                }
                Spacer()
            }
        }
    }
}


private struct HeaderMenu<Frame:TableDataFrame>: ViewModifier {
    let column: Frame.ColumnId
    let tableState: Binding<TableState<Frame>>
    let dataLoader: TableDataLoader<Frame>
    
    func body(content: Content) -> some View {
        content.contextMenu {
            Button(action: {
                self.tableState.wrappedValue.hideColumn(id: self.column)
            }) {
                Text("Hide Column").disabled(tableState.wrappedValue.visibleColumnCount > 1)
            }
            Button(action: {
            }) {
                Text("Fit Width")
            }
            VStack {
                Divider()
            }
            Button(action: {
                self.tableState.wrappedValue.unhideColumns()
            }) {
                Text("Unhide All")
            }
            Button(action: { self.dataLoader.load(forState: self.tableState)
            }) {
                Text("Refresh")
            }
        }
        
    }

}
