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
    
    var body: some View {
        ZStack {
            // Game view
            SpriteView(scene: gameScene)
                .ignoresSafeArea()
                .zIndex(-1)
            
            // Score Overlay
            if !gameScene.isShowingTitleScreen && !gameScene.isShowingHighScores {
                ScoreView()
            }
            // Title screen
            if gameScene.isShowingTitleScreen {
                TitleView()
            // Game over overlay
            } else if gameScene.isShowingGameOverScreen && !gameScene.isShowingHighScores {
                GameOverView()
            }
            
            // Pause overlay
            if gameScene.showPauseView {
                PauseView()
            }
            
            // High Scores
            if gameScene.isShowingHighScores {
                HighScoresView()
            }
        }
    }
}
