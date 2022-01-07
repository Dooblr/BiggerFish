//
//  TitleView.swift
//  BiggerFish
//
//  Created by admin on 1/6/22.
//

import SwiftUI

struct TitleView: View {
    
    @EnvironmentObject var gameScene:GameScene
    
    var body: some View {
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
//            Button {
//                
//            } label: {
//                CustomButton(text: "Settings", color: .blue)
//            }
            Button {
                gameScene.isShowingTitleScreen = false
                gameScene.isShowingHighScores = true
            } label: {
                CustomButton(text: "High Scores", color: .yellow)
            }
        }
        .zIndex(0)
    }
}

struct TitleView_Previews: PreviewProvider {
    static var previews: some View {
        TitleView()
    }
}
