//
//  ContentView.swift
//  BiggerFish
//
//  Created by admin on 12/26/21.
//

import SwiftUI
import SpriteKit

struct ContentView: View {
    
    @StateObject var gameScene = GameScene()
    
    var body: some View {
        ZStack {
            SpriteView(scene: gameScene)
                .ignoresSafeArea()
                .zIndex(-1)
            if !gameScene.isShowingTitleScreen {
                VStack{
                    Spacer()
                    HStack{
                        Spacer()
                        Text("Score: \(gameScene.score)").bold()
                            .padding()
                        
                    }
                }
            }
            
            if gameScene.isShowingTitleScreen {
                // Title screen
                VStack {
                    Text("Bigger Fish")
                        .font(.largeTitle)
                        .padding()
                    Button {
                        gameScene.isShowingTitleScreen = false
                        gameScene.isShowingGameOverScreen = false
                        gameScene.startGame()
                    } label: {
                        CustomButton(text: "Play", color: .green)
                    }
                    
                    // TODO: - Settings & Leaderboards
                    Button {
                        
                    } label: {
                        CustomButton(text: "Settings", color: .blue)
                    }
                    Button {
                        
                    } label: {
                        CustomButton(text: "Leaderboards", color: .yellow)
                    }
                }
                .zIndex(0)
            } else if gameScene.isShowingGameOverScreen {
                VStack {
                    Text("Game Over!")
                        .font(.largeTitle)
                        .padding()
                    Text("Final score: \(gameScene.score)")
                        .font(.title)
                        .padding(.bottom)
                    // Play again button
                    Button {
                        gameScene.isShowingGameOverScreen = false
                        gameScene.startGame()
                    } label: {
                        CustomButton(text: "Play again", color: .green)
                    }
                    // Main Menu button
                    Button {
                        gameScene.isShowingTitleScreen = true
                    } label: {
                        CustomButton(text: "Main menu", color: .blue)
                    }
                }
                .zIndex(0)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
