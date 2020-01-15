//
//  AppDelegate.swift
//  DynoDbViewer
//
//  Created by RedPanda on 31-Oct-19.
//  Copyright © 2019 strictlyswift. All rights reserved.
//

import Cocoa
import SwiftUI
import Dyno
import DynoTableDataView

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var window: NSWindow!
    static let 🦕 : Dyno = Dyno(options: DynoOptions(log: true))!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Create the SwiftUI view that provides the window contents.
//        let contentView = DynoTableDataView<DynoObjectFrame>(dyno: Self.🦕, table:"Dinosaurs")
        let contentView = DynoTableDataView<DynoTable<Dinosaur>>(dyno: Self.🦕, table:"Dinosaurs")

        // Create the window and set the content view. 
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false)
        window.center()
        window.title = "Dinosaurs"
        window.setFrameAutosaveName("Main Window")
        window.contentView = NSHostingView(rootView: contentView)
        window.makeKeyAndOrderFront(nil)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

