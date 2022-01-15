//
//  TitleView.swift
//  BiggerFish
//
//  Created by admin on 1/6/22.
//

import SwiftUI

struct TitleView: View {
    
    @EnvironmentObject var gameScene:GameScene
    @EnvironmentObject var interfaceControls:InterfaceControls
    
    var body: some View {
        VStack {
            
            // Title
            Text("Bigger Fish")
                .font(.largeTitle)
                .padding()
            
            // Play Button
            Button {
                InterfaceControls.interfaceState = .playing
                gameScene.startGame()
            } label: {
                CustomButton(text: "Play", color: .green)
            }
            
            // High scores button
            Button {
                InterfaceControls.interfaceState = .highScores
                gameScene.reload.toggle()
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
