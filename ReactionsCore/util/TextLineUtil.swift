//
// Reactions App
//

import CoreGraphics

public struct TextLineUtil {

    private init() { }

    private static var numberFormatter: NumberFormatter  = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .scientific
        formatter.maximumSignificantDigits = 2
        formatter.exponentSymbol = "x10"
        return formatter
    }()

    public static func scientific(
        value: CGFloat
    ) -> TextLine {
        if let scientificValue = numberFormatter.string(for: value) {
            return parseScientificValue(value: scientificValue)
        }

        return TextLine(value.str(decimals: 2))
    }

    private static func parseScientificValue(
        value: String
    ) -> TextLine {
        let defaultValue = TextLine(value)
        guard let xIndex = value.firstIndex(of: "x") else {
            return defaultValue
        }
        let zeroIndex = value.index(xIndex, offsetBy: 2)
        guard zeroIndex < value.endIndex else {
            return defaultValue
        }

        let xToZero = value[xIndex...zeroIndex]
        guard xToZero == "x10" else {
            return defaultValue
        }

        let powerIndex = value.index(after: zeroIndex)
        guard powerIndex < value.endIndex else {
            return defaultValue
        }

        let firstPart = value[..<powerIndex]
        let endPart = value[powerIndex...]

        return TextLine("\(firstPart)^\(endPart)^")
    }

}
