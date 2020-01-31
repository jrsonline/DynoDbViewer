//
//  SceneDelegate.swift
//  iPadDynoDbViewer
//
//  Created by RedPanda on 28-Nov-19.
//  Copyright © 2019 strictlyswift. All rights reserved.
//

import UIKit
import SwiftUI
import Dyno
import DynoTableDataView

let OB_KEY_2 = "SceneDelegate"

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // This method of obfuscation is VERY simple and not really suitable for
        // production code
        let region = NSDataAsset(name:"Region")
        let credentials = _obfuscate(data: NSDataAsset(name: "Credentials")!.data, key1: OB_KEY_1, key2: OB_KEY_2, deobfuscate: true)
        let 🦕 : Dyno = Dyno(region: String(data: region!.data, encoding: .utf8),
                               credentialData: credentials,
                               options: DynoOptions(log: true))!

        let contentView = DynoTableDataView<DynoTable<Dinosaur>>(dyno: 🦕, table:"Dinosaurs", autoRefreshPeriod: 5)
        
        // Use a UIHostingController as window root view controller.
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView: contentView)
            self.window = window
            window.makeKeyAndVisible()
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}


infix operator %%
func %% (n:Int, mod:Int) -> Int {
    let m = (n % mod)
    if m < 0 {
        return (m+mod)
    } else {
        return m
    }
}
func _obfuscate(data: Data, key1: String, key2: String, deobfuscate: Bool = false) -> Data {
    let dkey = (key1+key2).data(using: .ascii)!
    
    var keyIdx = 0
    var outData = ""
    
    for d in data {
        let val = Int(d) + Int(dkey[keyIdx]) * (deobfuscate ? -1 : 1)
        let p = Data(repeating: UInt8( val %% 128 ), count: 1)
        outData += String(data: p, encoding: .ascii)!
        keyIdx = (keyIdx+1) % dkey.count
    }
    return outData.data(using: .ascii)!
}
