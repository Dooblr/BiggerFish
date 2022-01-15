//
//  HighScoresListView.swift
//  BiggerFish
//
//  Created by admin on 1/10/22.
//

import SwiftUI

struct HighScoresListView: View {
    
    let userDefaults = UserDefaults.standard
    
    var highScores:[String:Int]?
    
    init(){
        highScores = userDefaults.dictionary(forKey: "HighScoresDict") as? [String : Int]
    }
    
    var body: some View {
        VStack {
            ForEach(highScores!.sorted(by: { $0.value > $1.value }), id: \.key) { key, value in
                VStack {
                    HStack {
                        Text("\(key)")
                        Spacer()
                        Text("\(value)")
                    }.padding(.horizontal)
                    Divider()
                        .colorInvert()
                        .opacity(0.67)
                }
            }
        }
        .padding()
        .frame(width: UIScreen.main.bounds.width * 0.5, alignment: .leading)
        .foregroundColor(.black)
        .background(.white)
        .cornerRadius(10)
    }
}

struct HighScoresListView_Previews: PreviewProvider {
    static var previews: some View {
        HighScoresListView()
    }
}
