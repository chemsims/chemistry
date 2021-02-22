//
// ReactionsCore
//

import SwiftUI
import SpriteKit

public struct RGB {
    let r: Double
    let g: Double
    let b: Double

    public var color: Color {
        Color(red: r / 255, green: g / 255, blue: b / 255)
    }

    public var skColor: SKColor {
        SKColor(red: CGFloat(r / 255), green: CGFloat(g / 255), blue: CGFloat(b / 255), alpha: 1)
    }

    public var uiColor: UIColor {
        UIColor(red: CGFloat(r / 255), green: CGFloat(g / 255), blue: CGFloat(b / 255), alpha: 1)
    }
}

extension RGB {
    public static let moleculeA = RGB(r: 8, g: 168, b: 232)
    public static let moleculeB = RGB(r: 255, g: 19, b: 19)
    public static let moleculeC = RGB(r: 225, g: 132, b: 19)

    public static let moleculeD = RGB(r: 213, g: 111, b: 62)
    public static let moleculeE = RGB(r: 99, g: 105, b: 209)
    public static let moleculeF = RGB(r: 84, g: 35, b: 68)

    public static let moleculeG = RGB(r: 156, g: 109, b: 138)
    public static let moleculeH = RGB(r: 27, g: 153, b: 139)
    public static let moleculeI = RGB(r: 221, g: 183, b: 113)
}

public struct Styling {
    public static let beakerOuterTone = Color.black.opacity(0.15)
    public static let beakerInnerTone = Color.black.opacity(0.075)

    public static let beakerLiquid = Color(red: 218 / 255, green: 238 / 255, blue: 245 / 255)
    public static let beakerOutline = Color.darkGray

    public static let moleculePlaceholder = Color(red: 206 / 255, green: 227 / 255, blue: 237 / 255)

    public static let moleculeA = RGB.moleculeA.color
    public static let moleculeB = RGB.moleculeB.color
    public static let moleculeC = RGB.moleculeC.color

    public static let moleculeAChartHeadHalo = Color(red: 143 / 255, green: 190 / 255, blue: 226 / 255, opacity: 0.7)

    public static let speechBubble = RGB(r: 232, g: 232, b: 232).color

    public static let primaryColorHalo = Color.orangeAccent.opacity(0.5)

    public static let energyProfileCompleteBar = UIColor.gray.color
    public static let timeAxisCompleteBar = UIColor.systemGray3.color
    public static let barChartEmpty = UIColor.systemGray4.color

    public static let energySliderBar = RGB(r: 170, g: 170, b: 170).color

    public static let tooltipBackground = Color(red: 66 / 255, green: 66 / 255, blue: 66 / 255, opacity: 1)
    public static let tooltipText = Color.white
    public static let tooltipBorder = Color(red: 161 / 255, green: 161 / 255, blue: 161 / 255, opacity: 1)

    public static let comparisonOrder0Background = RGB(r: 242, g: 252, b: 255).color
    public static let comparisonOrder0Border = RGB(r: 86, g: 188, b: 239).color
    public static let comparisonOrder1Background = RGB(r: 251, g: 234, b: 233).color
    public static let comparisonOrder1Border = RGB(r: 222, g: 52, b: 39).color
    public static let comparisonOrder2Background = RGB(r: 254, g: 251, b: 237).color
    public static let comparisonOrder2Border = RGB(r: 248, g: 209, b: 74).color

    public static let comparisonEquationDisabled = RGB(r: 239, g: 239, b: 239).color
    public static let comparisonEquationDisabledBorder = RGB(r: 140, g: 140, b: 140).color

    public static let inactiveScreenElement = RGB(r: 200, g: 200, b: 200).color

    public static let menuPanel = RGB(r: 242, g: 242, b: 242).color

    public static let navIcon = RGB(r: 68, g: 150, b: 247).color
    public static let navIconSelected = RGB(r: 91, g: 141, b: 197).color

    public static let tableOddRow = RGB(r: 240, g: 240, b: 240).color
    public static let tableEvenRow = RGB(r: 230, g: 230, b: 230).color
    public static let tableCellBorder = RGB(r: 190, g: 190, b: 190).color
}

extension UIColor {
    public static let catalystA = UIColor(red: 246 / 255, green: 83  / 255, blue: 166 / 255, alpha: 1)
    public static let catalystB = UIColor(red: 227 / 255, green: 215  / 255, blue: 89 / 255, alpha: 1)
    public static let catalystC = UIColor(red: 152 / 255, green: 251  / 255, blue: 251 / 255, alpha: 1)

    var color: Color { Color(self) }
}

extension Color {
    public static let darkGray = Color(red: 0.25, green: 0.25, blue: 0.25)
    public static let orangeAccent = Color(red: 220 / 255, green: 84 / 255, blue: 59 / 255)
}

extension Styling {
    public struct Quiz {

        private static let standardActive = Color.white

        private static let lightGray = RGB(r: 245, g: 245, b: 245).color
        private static let veryLightGray = RGB(r: 249, g: 249, b: 249).color

        private static let lightBlue = RGB(r: 232, g: 244, b: 250).color
        private static let darkBlue = RGB(r: 96, g: 147, b: 202).color

        private static let lightRed = RGB(r: 247, g: 237, b: 234).color
        private static let darkRed = RGB(r: 212, g: 91, b: 73).color
        private static let veryDarkRed = RGB(r: 198, g: 67, b: 47).color

        private static let lightGreen = RGB(r: 233, g: 243, b: 238).color
        private static let darkGreen = RGB(r: 95, g: 181, b: 128).color
        private static let veryDarkGreen = RGB(r: 56, g: 121, b: 81).color

        public static let progressBackground = Styling.inactiveScreenElement
        public static let progressForeground = darkBlue

        public static let selectedDifficultyBackground = lightBlue
        public static let selectedDifficultyBorder = darkBlue

        public static let unselectedDifficultyCount = Styling.inactiveScreenElement

        public static let correctAnswerBackground = lightGreen
        public static let correctAnswerBorder = darkGreen

        public static let wrongAnswerBorder = darkRed
        public static let wrongAnswerBackground = lightRed

        public static let answerBackground = Color.white
        public static let disabledAnswerBackground = lightGray

        public static let explanationBackground = veryLightGray

        public static let infoIconForeground = darkBlue
        public static let infoIconBackground = lightBlue

        public static let reviewCorrectAnswerFont = veryDarkGreen
        public static let reviewWrongAnswerFont = veryDarkRed
    }
}
