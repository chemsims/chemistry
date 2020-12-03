//
// Reactions App
//
  

import SwiftUI
import SpriteKit

struct Styling {
    static let beakerOuterTone = Color.black.opacity(0.15)
    static let beakerInnerTone = Color.black.opacity(0.075)

    static let beakerLiquid = Color(red: 218 / 255, green: 238 / 255, blue: 245 / 255)

    static let moleculePlaceholder = Color(red: 206 / 255, green: 227 / 255, blue: 237 / 255)

    static let moleculeA = UIColor.moleculeA.color
    static let moleculeB = UIColor.moleculeB.color


    static let moleculeAChartHeadHalo = Color(red: 143 / 255, green: 190 / 255, blue: 226 / 255, opacity: 0.7)

    static let speechBubble = Color(red: 0.91, green: 0.91, blue: 0.91)

    static let primaryColorHalo = Color.orangeAccent.opacity(0.5)

    static let timeAxisCompleteBar = UIColor.systemGray3.color
    static let barChartEmpty = UIColor.systemGray4.color
}

extension UIColor {

    static let moleculeA = UIColor(red: 8 / 255, green: 168 / 255, blue: 232  / 255, alpha: 1)
    static let moleculeB = UIColor(red: 255 / 255, green: 19 / 255, blue: 19 / 255, alpha: 1)
    static let moleculeC = UIColor(red: 226 / 255, green: 132 / 255, blue: 19 / 255, alpha: 1)

    static let catalystA = UIColor(red: 246 / 255, green: 83  / 255, blue: 166 / 255, alpha: 1)
    static let catalystB = UIColor(red: 227 / 255, green: 215  / 255, blue: 89 / 255, alpha: 1)
    static let catalystC = UIColor(red: 152 / 255, green: 251  / 255, blue: 251 / 255, alpha: 1)

    var color: Color { Color(self) }
}

extension Color {
    static let darkGray = Color(red: 0.25, green: 0.25, blue: 0.25)
    static let orangeAccent = Color(red: 220 / 255, green: 84 / 255, blue: 59 / 255)

}

