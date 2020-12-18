//
// Reactions App
//
  

import SwiftUI
import SpriteKit

struct RGB {
    let r: Double
    let g: Double
    let b: Double

    var color: Color {
        Color(red: r / 255, green: g / 255, blue: b / 255)
    }
}

struct Styling {
    static let beakerOuterTone = Color.black.opacity(0.15)
    static let beakerInnerTone = Color.black.opacity(0.075)

    static let beakerLiquid = Color(red: 218 / 255, green: 238 / 255, blue: 245 / 255)
    static let beakerOutline = Color.darkGray

    static let moleculePlaceholder = Color(red: 206 / 255, green: 227 / 255, blue: 237 / 255)

    static let moleculeA = UIColor.moleculeA.color
    static let moleculeB = UIColor.moleculeB.color


    static let moleculeAChartHeadHalo = Color(red: 143 / 255, green: 190 / 255, blue: 226 / 255, opacity: 0.7)

    static let speechBubble = RGB(r: 232, g: 232, b: 232).color

    static let primaryColorHalo = Color.orangeAccent.opacity(0.5)

    static let energyProfileCompleteBar = UIColor.gray.color
    static let timeAxisCompleteBar = UIColor.systemGray3.color
    static let barChartEmpty = UIColor.systemGray4.color

    static let energySliderBar = RGB(r: 170, g: 170, b: 170).color

    static let tooltipBackground = Color(red: 66 / 255, green: 66 / 255, blue: 66 / 255, opacity: 1)
    static let tooltipText = Color.white
    static let tooltipBorder = Color(red: 161 / 255, green: 161 / 255, blue: 161 / 255, opacity: 1)

    static let comparisonOrder0Background = RGB(r: 242, g: 252, b: 255).color
    static let comparisonOrder0Border = RGB(r: 86, g: 188, b: 239).color
    static let comparisonOrder1Background = RGB(r: 251, g: 234, b: 233).color
    static let comparisonOrder1Border = RGB(r: 222, g: 52, b: 39).color
    static let comparisonOrder2Background = RGB(r: 254, g: 251, b: 237).color
    static let comparisonOrder2Border = RGB(r: 248, g: 209, b: 74).color

    static let comparisonEquationDisabled = RGB(r: 239, g: 239, b: 239).color
    static let comparisonEquationDisabledBorder = RGB(r: 140, g: 140, b: 140).color

    static let inactiveScreenElement = RGB(r: 200, g: 200, b: 200).color

    static let menuPanel = RGB(r: 242, g: 242, b: 242).color

    static let quizProgressBackground = RGB(r: 245, g: 203, b: 196).color
    static let quizProgressBorder = RGB(r: 240, g: 179, b: 168).color
    static let quizAnswer = RGB(r: 143, g: 184, b: 222).color
    static let quizAnswerBorder = RGB(r: 114, g: 165, b: 213).color
    static let quizAnswerInactive = RGB(r: 191, g: 207, b: 222).color
    static let quizAnswerCorrectBorder = RGB(r: 38, g: 83, b: 43).color
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

