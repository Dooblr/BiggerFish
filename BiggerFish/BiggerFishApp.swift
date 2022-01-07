//
//  BiggerFishApp.swift
//  BiggerFish
//
//  Created by admin on 12/26/21.
//

import SwiftUI

@main
struct BiggerFishApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .statusBar(hidden: true)
                .environmentObject(GameScene())
        }
    }
}
