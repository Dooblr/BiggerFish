//
//  InterfaceControls.swift
//  BiggerFish
//
//  Created by admin on 1/10/22.
//

import Foundation
import SwiftUI

enum InterfaceState {
    case gameOver
    case title
    case highScores
    case playing
    case paused
}

class InterfaceControls: ObservableObject {
    
    static var interfaceState:InterfaceState = .title
    
    static var levelUp = false
}
