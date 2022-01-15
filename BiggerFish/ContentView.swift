//
//  ContentView.swift
//  BiggerFish
//
//  Created by admin on 12/26/21.
//

import SwiftUI
import SpriteKit

struct ContentView: View {
    
    @EnvironmentObject var gameScene:GameScene
    @EnvironmentObject var interfaceControls:InterfaceControls
    
    var body: some View {
        ZStack {
            // Game view
            SpriteView(scene: gameScene)
                .ignoresSafeArea()
                .zIndex(-1)
            
            // Score Overlay
            if InterfaceControls.interfaceState != .title && InterfaceControls.interfaceState != .highScores {
                ScoreView()
            }
            // Title screen
            if InterfaceControls.interfaceState == .title {
                TitleView()
            // Game over overlay
            }
            
            if InterfaceControls.interfaceState == .gameOver {
                GameOverView()
            }
            
            // Pause overlay
            if InterfaceControls.interfaceState == .paused {
                PauseView()
            }
            
            // High Scores
            if InterfaceControls.interfaceState == .highScores {
                HighScoresView()
            }
        }
    }
}
