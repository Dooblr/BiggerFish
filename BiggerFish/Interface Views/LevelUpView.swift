//
//  LevelUpView.swift
//  BiggerFish
//
//  Created by admin on 1/26/22.
//

import SwiftUI

struct LevelUpView: View {
    var body: some View {
        VStack{
            Spacer()
            StrokeText(text: "Level Up!", width: 0.5, color: .black)
                        .foregroundColor(.white)
                        .font(.system(size: 32, weight: .bold))
            Spacer()
        }.zIndex(1)
    }
}

struct LevelUpView_Previews: PreviewProvider {
    static var previews: some View {
        LevelUpView()
    }
}
