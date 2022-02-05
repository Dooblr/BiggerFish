//
//  TitleScreenView.swift
//  BiggerFish
//
//  Created by admin on 1/6/22.
//

import SwiftUI

struct ScoreView: View {
    
    @EnvironmentObject var gameScene:GameScene
    
    var body: some View {
        VStack{
            Spacer()
            HStack{
                Spacer()
                VStack {
                    Text("Score: \(gameScene.score)").bold()
                    Text("Level: \(gameScene.level)").bold()
                }.padding()
            }
        }
    }
}
