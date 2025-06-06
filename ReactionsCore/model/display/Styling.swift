//
// ReactionsCore
//

import SwiftUI
import SpriteKit
import CogSciKit

public struct RGB {
    public let r: Double
    public let g: Double
    public let b: Double
    public let opacity: Double

    public init(r: Double, g: Double, b: Double, opacity: Double = 1) {
        self.r = r
        self.g = g
        self.b = b
        self.opacity = opacity
    }

    public static func gray(base: Double) -> RGB {
        RGB(r: base, g: base, b: base)
    }

    public var color: Color {
        Color(red: r / 255, green: g / 255, blue: b / 255, opacity: opacity)
    }

    public var skColor: SKColor {
        SKColor(red: CGFloat(r / 255), green: CGFloat(g / 255), blue: CGFloat(b / 255), alpha: CGFloat(opacity))
    }

    public var uiColor: UIColor {
        UIColor(red: CGFloat(r / 255), green: CGFloat(g / 255), blue: CGFloat(b / 255), alpha: CGFloat(opacity))
    }

    public func withOpacity(_ newOpacity: Double) -> RGB {
        RGB(r: r, g: g, b: b, opacity: newOpacity)
    }
}

extension RGB {
    public static func interpolate(_ left: RGB, _ right: RGB, fraction: Double) -> RGB {

        func interpolateElement(_ l: Double, _ r: Double) -> Double {
            l + ((r - l) * fraction)
        }

        return RGB(
            r: interpolateElement(left.r, right.r),
            g: interpolateElement(left.g, right.g),
            b: interpolateElement(left.b, right.b),
            opacity: interpolateElement(left.opacity, right.opacity)
        )
    }
}

extension RGB {
    public static let black = RGB(r: 0, g: 0, b: 0)

    public static let moleculeA = RGB(r: 8, g: 168, b: 232)
    public static let moleculeB = RGB(r: 255, g: 19, b: 19)
    public static let moleculeC = RGB(r: 225, g: 132, b: 19)

    public static let moleculeD = RGB(r: 213, g: 111, b: 62)
    public static let moleculeE = RGB(r: 99, g: 105, b: 209)
    public static let moleculeF = RGB(r: 84, g: 35, b: 68)

    public static let moleculeG = RGB(r: 156, g: 109, b: 138)
    public static let moleculeH = RGB(r: 27, g: 153, b: 139)
    public static let moleculeI = RGB(r: 221, g: 183, b: 113)

    public static let beakerLiquid = RGB(r: 218, g: 238, b: 245)

    public static let primaryLightBlue = RGB(r: 169, g: 204, b: 229)
    public static let primaryDarkBlue = RGB(r: 97, g: 147, b: 201)
}

public struct Styling {

    public static let scalesBody = RGB.gray(base: 130).color
    public static let scalesBadgeOutline = RGB.gray(base: 100).color

    public static let beakerOuterTone = Color.black.opacity(0.15)
    public static let beakerInnerTone = Color.black.opacity(0.075)

    public static let beakerLiquid = RGB.beakerLiquid.color
    public static let beakerAir = RGB.gray(base: 235).color
    public static let beakerOutline = Color.darkGray
    public static let beakerTicks = Color.darkGray.opacity(0.5)

    public static let moleculePlaceholder = Color(red: 206 / 255, green: 227 / 255, blue: 237 / 255)
    public static let airMoleculePlaceholder = RGB.gray(base: 225).color

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

    public static let switchBackground = RGB.gray(base: 210).color

    public static let inactiveContainerMultiply = RGB.gray(base: 160).color
}

extension UIColor {
    public static let catalystA = UIColor(red: 246 / 255, green: 83  / 255, blue: 166 / 255, alpha: 1)
    public static let catalystB = UIColor(red: 227 / 255, green: 215  / 255, blue: 89 / 255, alpha: 1)
    public static let catalystC = UIColor(red: 152 / 255, green: 251  / 255, blue: 251 / 255, alpha: 1)

    var color: Color { Color(self) }
}

extension Color {
    public static let darkGray = Color(red: 0.25, green: 0.25, blue: 0.25)
    public static let orangeAccent = CorePalette.orangeAccent

    public static let primaryDarkBlue = RGB.primaryDarkBlue.color
    public static let primaryLightBlue = RGB.primaryLightBlue.color

    public static func from(_ rgb: RGB) -> Color {
        rgb.color
    }
}
