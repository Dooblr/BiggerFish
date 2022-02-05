//
//  HighScoresView.swift
//  BiggerFish
//
//  Created by admin on 1/6/22.
//

import SwiftUI
//import OrderedCollections

struct HighScoresView: View {
    
    @EnvironmentObject var gameScene:GameScene
    
    let userDefaults = UserDefaults.standard
    
    var highScores:[String:Int]?
    
    init(){
        highScores = userDefaults.dictionary(forKey: "HighScoresDict") as? [String : Int]
    }
    
    var body: some View {
        VStack{
            if highScores!.isEmpty {
                Text("No high scores yet. Get munching!")
            }
            HighScoresListView()
            Button {
                InterfaceControls.interfaceState = .title
                gameScene.reload.toggle()
            } label: {
                CustomButton(text: "Close", color: .yellow)
            }

        }.zIndex(1)
    }
}

struct HighScoresView_Previews: PreviewProvider {
    static var previews: some View {
        HighScoresView()
    }
}
