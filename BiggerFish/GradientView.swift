//
//  GradientView.swift
//  BiggerFish
//
//  Created by admin on 1/31/22.
//

import SwiftUI

struct GradientView: View {
    
    @State private var progress: CGFloat = 0
//    var color1 = Color(red: 68/255, green: 198/255, blue: 198/255)
//    var color2 = Color.blue
    let gradient1 = Gradient(colors: [.purple, .yellow])
    let gradient2 = Gradient(colors: [.blue, .purple])
    
    var body: some View {
        LinearGradient(gradient: gradient1, startPoint: UnitPoint(x: 0.5, y: 1), endPoint: UnitPoint(x: 0.5, y: 0))
            .animatableGradient(fromGradient: gradient1, toGradient: gradient2, progress: progress)
            .ignoresSafeArea()
            .onAppear {
                withAnimation(.linear(duration: 5.0).repeatForever(autoreverses: true)) {
                    self.progress = 1.0
                }
            }
    }
}

//

extension View {
    func animatableGradient(fromGradient: Gradient, toGradient: Gradient, progress: CGFloat) -> some View {
        self.modifier(AnimatableGradientModifier(fromGradient: fromGradient, toGradient: toGradient, progress: progress))
    }
}

struct AnimatableGradientModifier: AnimatableModifier {
    let fromGradient: Gradient
    let toGradient: Gradient
    var progress: CGFloat = 0.0
 
    var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }
 
    func body(content: Content) -> some View {
        var gradientColors = [Color]()
 
        for i in 0..<fromGradient.stops.count {
            let fromColor = UIColor(fromGradient.stops[i].color)
            let toColor = UIColor(toGradient.stops[i].color)
 
            gradientColors.append(colorMixer(fromColor: fromColor, toColor: toColor, progress: progress))
        }
 
        return LinearGradient(gradient: Gradient(colors: gradientColors), startPoint: .topLeading, endPoint: .bottomTrailing)
    }
 
    func colorMixer(fromColor: UIColor, toColor: UIColor, progress: CGFloat) -> Color {
        guard let fromColor = fromColor.cgColor.components else { return Color(fromColor) }
        guard let toColor = toColor.cgColor.components else { return Color(toColor) }
 
        let red = fromColor[0] + (toColor[0] - fromColor[0]) * progress
        let green = fromColor[1] + (toColor[1] - fromColor[1]) * progress
        let blue = fromColor[2] + (toColor[2] - fromColor[2]) * progress
 
        return Color(red: Double(red), green: Double(green), blue: Double(blue))
    }
}
