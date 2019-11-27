//
//  TableDataSourceLoader.swift
//  DynoDbViewer
//
//  Created by RedPanda on 15-Nov-19.
//  Copyright © 2019 strictlyswift. All rights reserved.
//

import Foundation
import Combine
import SwiftUI

struct TableDataSourceLoadError : Error {
    let msg: String
}

/*

class TableDataSourceLoader<M : TableDataSource> : ObservableObject {
    @Published private(set) var result: [M]? =  nil
    @Published private(set) var columns: [M.ColumnId] = []
    @Published private(set) var haveError: Error? = nil
    @Published private(set) var amLoading: LoadState = .idle
    internal var cancellable: AnyCancellable?
    
    let loader: (String?) -> AnyPublisher<[M],Error>
    let table: String?
    
    init(loader: @escaping (String?) -> AnyPublisher<[M],Error> ,
         table: String? = nil) {
        self.loader = loader
        self.table = table
    }
    
    internal enum LoadState {
        case idle, loadingInitialised, loadingUnderway
    }
    
    func load() {
        self.cancellable =
            self.loader(table)
                .handleEvents(receiveSubscription: { [weak self] s in DispatchQueue.main.async {
                    self?.amLoading = .loadingInitialised
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                        if self?.amLoading == .loadingInitialised {
                            self?.amLoading = .loadingUnderway
                        }
                    }
                    }
                    },receiveCancel: {
                        DispatchQueue.main.async {
                            self.haveError = TableDataSourceLoadError(msg:"Cancelled")
                        }
                })
                .sink(receiveCompletion: { [weak self] x in
                    DispatchQueue.main.async {
                        if case  .failure(let error) = x {
                            self?.haveError = error
                        }
                        self?.amLoading = .idle
                    }
                    },
                      receiveValue:{ [weak self] dinos in
                        DispatchQueue.main.async {
                            self?.haveError = nil
                            self?.result = dinos
                        }
                })
    }
    
    func cancel() {
        self.cancellable?.cancel()
    }
    
    deinit {
        self.cancel()
    }
    
    /// Show a simple activity spinner whilst the data is loading
    func activitySpinner() -> some View {
        Group {
            if self.amLoading == .loadingUnderway {
                ActivityIndicator()
            }
            else {
                EmptyView()
            }
        }
    }
}

*/

class TableDataLoader<Frame : TableDataFrame> : ObservableObject {
    @Published private(set) var frame: Frame?
    @Published private(set) var haveError: Error? = nil
    @Published private(set) var amLoading: LoadState = .idle
    internal var cancellable: AnyCancellable?
    
    let loader: (String?) -> AnyPublisher<Frame,Error>
    let table: String?
 //   var tableState: TableState<Frame>
    
    init(loader: @escaping (String?) -> AnyPublisher<Frame,Error> ,
         table: String? = nil) {
        self.loader = loader
        self.table = table
 //       self.tableState = tableState
    }
    
    internal enum LoadState {
        case idle, loadingInitialised, loadingUnderway
    }
    
    func load(forState tableState: Binding<TableState<Frame>>) {
        self.cancellable =
            self.loader(table)
                .handleEvents(receiveSubscription: { [weak self] s in DispatchQueue.main.async { 
                    self?.amLoading = .loadingInitialised
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                        if self?.amLoading == .loadingInitialised {
                            self?.amLoading = .loadingUnderway
                        }
                    }
                    }
                    },receiveCancel: {
                        DispatchQueue.main.async {
                            self.haveError = TableDataSourceLoadError(msg:"Cancelled")
                        }
                })
                .sink(receiveCompletion: { [weak self] x in
                    DispatchQueue.main.async {
                        if case  .failure(let error) = x {
                            self?.haveError = error
                        }
                        self?.amLoading = .idle
                    }
                    },
                      receiveValue:{ [weak self] frame in
                        DispatchQueue.main.async {
                            self?.haveError = nil
                            self?.frame = frame
                            tableState.wrappedValue.loaded(frame: frame)
                        }
                })
    }
    
    func cancel() {
        self.cancellable?.cancel()
    }
    
    deinit {
        self.cancel()
    }
    
    /// Show a simple activity spinner whilst the data is loading
    func activitySpinner() -> some View {
        Group {
            if self.amLoading == .loadingUnderway {
                ActivityIndicator()
            }
            else {
                EmptyView()
            }
        }
    }
}

// From: https://jetrockets.pro/blog/activity-indicator-in-swiftui
public struct ActivityIndicator: View {
  @State private var isAnimating: Bool = false

  public var body: some View {
    GeometryReader { (geometry: GeometryProxy) in
      ForEach(0..<2) { index in
        Group {
          Circle()
            .frame(width: geometry.size.width / 4, height: geometry.size.height / 4)
            .scaleEffect(!self.isAnimating ? 1 - CGFloat(index) / 5 : 0.2 + CGFloat(index) / 5)
            .offset(y: geometry.size.width / 10 - geometry.size.height / 2)
            .foregroundColor(Color.white)
          }.frame(width: geometry.size.width, height: geometry.size.height)
            .rotationEffect(!self.isAnimating ? .degrees(0) : .degrees(360))
            .animation(Animation
                .timingCurve(0.5, 0.15 + Double(index) / 5, 0.25, 1, duration: 1)
              .repeatForever(autoreverses: false))
        }

      }.aspectRatio(1, contentMode: .fit)
        .onAppear {
          self.isAnimating = true
        }
  }
}
