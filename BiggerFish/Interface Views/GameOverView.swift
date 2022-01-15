//
//  GameOverView.swift
//  BiggerFish
//
//  Created by admin on 1/6/22.
//

import SwiftUI

struct GameOverView: View {
    
    @EnvironmentObject var gameScene:GameScene
    @EnvironmentObject var interfaceControls:InterfaceControls
    
    let userDefaults = UserDefaults.standard
    
    @State var highScoreNameInput = ""
    @State var userHasSubmittedScore = false
    
    func setHighScore() {
        // Get userdefaults high scores dict
        var highScores = userDefaults.dictionary(forKey: "HighScoresDict") as! [String:Int]
        
        // if highscores has less than 5, add regardless of score
        if highScores.count < 5 {
            highScores.updateValue(gameScene.score, forKey: highScoreNameInput)
            userDefaults.set(highScores, forKey: "HighScoresDict")
        }
        // Or else get the lowest score from high scores
        else if let lowestScore = highScores.min(by: { a, b in a.value < b.value }) {
            if gameScene.score > lowestScore.value {
                highScores.removeValue(forKey: lowestScore.key)
                highScores.updateValue(gameScene.score, forKey: highScoreNameInput)
                userDefaults.set(highScores, forKey: "HighScoresDict")
            }
        }
        
    }
    
    var body: some View {
        VStack {
            
            Text("Game Over!")
                .font(.largeTitle)
                .padding()
            
            if gameScene.isHighScore {
                
                HStack {
                    Text("High score! :")
                        .font(.title)
                    Text("\(gameScene.score)")
                        .font(.title).bold()
                        .foregroundColor(.yellow)
                        .shadow(color: .gray, radius: 5, x: 2, y: -2)
                }
                
                if !userHasSubmittedScore {
                    // High score Name input
                    HStack {
                        TextField(
                            "Enter your name",
                            text: $highScoreNameInput
                        ).disableAutocorrection(true)
                    }
                    .padding()
                    .padding(EdgeInsets(top: 0, leading: 6, bottom: 0, trailing: 6))
                    .frame(width: UIScreen.main.bounds.width*0.67,height:48)
                    .cornerRadius(5)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(lineWidth: 1.0)
                    )
                    
                    // Submit high score button
                    Button {
                        setHighScore()
                        userHasSubmittedScore = true
                    } label: {
                        CustomButton(text: "Submit", color: .blue)
                    }
                    .padding(.bottom)
                } else {
                    HighScoresListView()
                        .padding()
                }
            } else {
                Text("Final score: \(gameScene.score)")
                    .font(.title)
                    .padding(.bottom)
            }
            
            // Play again button
            Button {
                InterfaceControls.interfaceState = .playing
                gameScene.reload.toggle()
                gameScene.startGame()
            } label: {
                CustomButton(text: "Play again", color: .green)
            }
            
            // Main Menu button
            Button {
                InterfaceControls.interfaceState = .title
                gameScene.reload.toggle()
            } label: {
                CustomButton(text: "Main menu", color: .blue)
            }
        }
        .zIndex(0)
    }
}

struct GameOverView_Previews: PreviewProvider {
    static var previews: some View {
        GameOverView()
    }
}
