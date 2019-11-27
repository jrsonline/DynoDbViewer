//
//  ContentView.swift
//  DynoDbViewer
//
//  Created by RedPanda on 31-Oct-19.
//  Copyright © 2019 strictlyswift. All rights reserved.
//

import SwiftUI
import Dyno
import Combine

#if os(macOS)
import Cocoa
#endif

let HEADER_HEIGHT : CGFloat = 30

extension View {
    func asAnyView() -> AnyView {
        return AnyView(self)
    }
}


struct TableDataView<F:TableDataFrame>: View {
    @ObservedObject var dataLoader : TableDataLoader<F>
    @State var tableState : TableState<F> = TableState()

    init(table: String? = nil) {
        self.dataLoader = TableDataLoader<F>(loader: F.load, table: table)
    }
    
    var body: some View {
        let results = self.dataLoader.frame

        return ZStack {
            VStack(alignment: .center, spacing:0) {
                if self.dataLoader.haveError != nil || results == nil {
                    Text("Failed to load data").background(Color.red)
                } else {
                    results!.headers(tableState: $tableState, dataLoader: dataLoader).frame(height:HEADER_HEIGHT)
                    ForEach( tableState.sorting(results!.content), id:\.self) { item in
                        item.tabulate(tableState: self.$tableState, tableDataFrame: results!)
                    }
                }
                Spacer()
                
            }
            VStack {
                 HStack {
                     self.dataLoader.activitySpinner()
                        .frame(width: 30, height: 30)
                     Spacer()
                 }
                 Spacer()
             }
            
        }
        .onAppear(perform: { self.dataLoader.load(forState: self.$tableState)} )
        .onDisappear(perform: dataLoader.cancel)
    }
}

/*
struct TableView<C:TableDataContainer>: View {
    @ObservedObject var dataLoader : TableDataSourceLoader<C.Content>
    @State var tableState : TableState<C.Content>

    init(table: String? = nil) {
        self.dataLoader = TableDataSourceLoader(loader: M.load, table: table)
        self.tableState = TableState(withLoader: self.dataLoader)
    }
    
    
    var body: some View {
        let results = self.dataLoader.result ?? Array<M>()

        return ZStack {
            VStack(alignment: .center, spacing:0) {
                M.headers(tableState: $tableState, dataLoader: dataLoader).frame(height:HEADER_HEIGHT)
                if self.dataLoader.haveError != nil {
                    Text("Failed to load data").background(Color.red)
                } else {
                    ForEach( tableState.sorting(results), id:\.self) { item in
                        item.tabulate(tableState: self.$tableState, dataLoader: self.dataLoader)
                    }
                }
                Spacer()
                
            }
            VStack {
                 HStack {
                     self.dataLoader.activitySpinner()
                        .frame(width: 30, height: 30)
                     Spacer()
                 }
                 Spacer()
             }
            
        }
        .onAppear(perform: dataLoader.load )
        .onDisappear(perform: dataLoader.cancel)
    }
}
*/
struct TableDataView_Previews: PreviewProvider {
    static var previews: some View {
        return EmptyView()
    //    TableDataView<Dinosaur>(loader: { Just( testDinos ).mapError { e in DynoError(e)}.eraseToAnyPublisher() })
    }
}

