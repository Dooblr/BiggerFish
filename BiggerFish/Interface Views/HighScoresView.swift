//
//  HighScoresView.swift
//  BiggerFish
//
//  Created by admin on 1/6/22.
//

import SwiftUI
import OrderedCollections

struct HighScoresView: View {
    
    @EnvironmentObject var gameScene:GameScene
    
    let userDefaults = UserDefaults.standard
    
    var highScores:[String:Int]?
    var orderedHighScores:OrderedDictionary<String, Int>?
    
    init(){
        highScores = userDefaults.dictionary(forKey: "HighScoresDict") as? [String : Int]
//        sortedHighScores = highScores!.sorted {
//            return $0.value > $1.value
//        }
//        orderedHighScores = OrderedDictionary(uniqueKeys: highScores!.keys, values: highScores!.values)
    }
    
    var body: some View {
        VStack{
            ForEach(highScores!.sorted(by: { $0.value > $1.value }), id: \.key) { key, value in
                HStack {
                    Text("\(key)").padding()
                    Text("\(value)")
                }
            }
            Button {
                gameScene.isShowingTitleScreen = true
                gameScene.isShowingHighScores = false
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
