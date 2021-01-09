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

    var skColor: SKColor {
        SKColor(red: CGFloat(r / 255), green: CGFloat(g / 255), blue: CGFloat(b / 255), alpha: 1)
    }

    var uiColor: UIColor {
        UIColor(red: CGFloat(r / 255), green: CGFloat(g / 255), blue: CGFloat(b / 255), alpha: 1)
    }
}

extension RGB {
    static let moleculeA = RGB(r: 8, g: 168, b: 232)
    static let moleculeB = RGB(r: 255, g: 19, b: 19)
    static let moleculeC = RGB(r: 225, g: 132, b: 19)

    static let moleculeD = RGB(r: 213, g: 111, b: 62)
    static let moleculeE = RGB(r: 99, g: 105, b: 209)
    static let moleculeF = RGB(r: 84, g: 35, b: 68)

    static let moleculeG = RGB(r: 156, g: 109, b: 138)
    static let moleculeH = RGB(r: 27, g: 153, b: 139)
    static let moleculeI = RGB(r: 221, g: 183, b: 113)
}

struct Styling {
    static let beakerOuterTone = Color.black.opacity(0.15)
    static let beakerInnerTone = Color.black.opacity(0.075)

    static let beakerLiquid = Color(red: 218 / 255, green: 238 / 255, blue: 245 / 255)
    static let beakerOutline = Color.darkGray

    static let moleculePlaceholder = Color(red: 206 / 255, green: 227 / 255, blue: 237 / 255)

    static let moleculeA = RGB.moleculeA.color
    static let moleculeB = RGB.moleculeB.color
    static let moleculeC = RGB.moleculeC.color

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

    static let quizActiveBlue = RGB(r: 232, g: 244, b: 250).color
    static let quizActiveDarkBlue = RGB(r: 96, g: 147, b: 202).color
    static let quizAnswerCorrectBackground = RGB(r: 233, g: 243, b: 238).color
    static let quizAnswerCorrectBorder = RGB(r: 95, g: 181, b: 128).color

    static let quizAnswerIncorrectBorder = RGB(r: 212, g: 91, b: 73).color
    static let quizAnswerIncorrectBackground = RGB(r: 247, g: 237, b: 234).color

    static let navIcon = RGB(r: 68, g: 150, b: 247).color
    static let navIconSelected = RGB(r: 91, g: 141, b: 197).color

    static let tableOddRow = RGB(r: 240, g: 240, b: 240).color
    static let tableEvenRow = RGB(r: 230, g: 230, b: 230).color
    static let tableCellBorder = RGB(r: 190, g: 190, b: 190).color
}


extension UIColor {
    static let catalystA = UIColor(red: 246 / 255, green: 83  / 255, blue: 166 / 255, alpha: 1)
    static let catalystB = UIColor(red: 227 / 255, green: 215  / 255, blue: 89 / 255, alpha: 1)
    static let catalystC = UIColor(red: 152 / 255, green: 251  / 255, blue: 251 / 255, alpha: 1)

    var color: Color { Color(self) }
}

extension Color {
    static let darkGray = Color(red: 0.25, green: 0.25, blue: 0.25)
    static let orangeAccent = Color(red: 220 / 255, green: 84 / 255, blue: 59 / 255)

}


extension Styling {
    struct Quiz {

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

        static let selectedDifficultyBackground = lightBlue
        static let selectedDifficultyBorder = darkBlue

        static let correctAnswerBackground = lightGreen
        static let correctAnswerBorder = darkGreen

        static let wrongAnswerBorder = darkRed
        static let wrongAnswerBackground = lightRed

        static let answerBackground = Color.white
        static let disabledAnswerBackground = lightGray

        static let explanationBackground = veryLightGray

        static let infoIconForeground = darkBlue
        static let infoIconBackground = lightBlue

        static let reviewCorrectAnswerFont = veryDarkGreen
        static let reviewWrongAnswerFont = veryDarkRed
    }
}
