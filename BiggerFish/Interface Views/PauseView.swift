//
//  PauseView.swift
//  BiggerFish
//
//  Created by admin on 1/6/22.
//

import SwiftUI

struct PauseView: View {
    var body: some View {
        VStack{
            Spacer()
            StrokeText(text: "Paused", width: 0.5, color: .black)
                        .foregroundColor(.white)
                        .font(.system(size: 32, weight: .bold))
            Spacer()
        }.zIndex(1)
    }
}

struct StrokeText: View {
    let text: String
    let width: CGFloat
    let color: Color

    var body: some View {
        ZStack{
            ZStack{
                Text(text).offset(x:  width, y:  width)
                Text(text).offset(x: -width, y: -width)
                Text(text).offset(x: -width, y:  width)
                Text(text).offset(x:  width, y: -width)
            }
            .foregroundColor(color)
            Text(text)
        }
    }
}

struct PauseView_Previews: PreviewProvider {
    static var previews: some View {
        PauseView()
    }
}
