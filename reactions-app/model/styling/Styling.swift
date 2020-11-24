//
// Reactions App
//
  

import SwiftUI
import SpriteKit

struct Styling {
    static let beakerOuterTone = Color.black.opacity(0.15)
    static let beakerInnerTone = Color.black.opacity(0.075)

    static let beakerLiquid = Color(red: 218 / 255, green: 238 / 255, blue: 245 / 255)
    static let beakerLiquidSK = SKColor(red: 218 / 255, green: 238 / 255, blue: 245 / 255, alpha: 1)

    static let moleculePlaceholder = Color(red: 206 / 255, green: 227 / 255, blue: 237 / 255)

    static let moleculeA = UIColor.moleculeA.color
    static let moleculeB = UIColor.moleculeB.color

    static let timeAxisCompleteBar = Color.gray

    static let moleculeAChartHeadHalo = Color(red: 143 / 255, green: 190 / 255, blue: 226 / 255, opacity: 0.7)

    static let speechBubble = Color(red: 0.91, green: 0.91, blue: 0.91)
}

extension UIColor {

    static let moleculeA = UIColor(red: 81 / 255, green: 155 / 255, blue: 210 / 255, alpha: 1)
    static let moleculeB = UIColor(red: 175 / 255, green: 11 / 255, blue: 8 / 255, alpha: 1)
    static let moleculeC = UIColor(red: 253 / 255, green: 231 / 255, blue: 76 / 255, alpha: 1)

    var color: Color { Color(self) }
}

extension Color {
    static let darkGray = Color(red: 0.25, green: 0.25, blue: 0.25)
    static let orangeAccent = Color(red: 220 / 255, green: 84 / 255, blue: 59 / 255)

}

