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
        formatter.minimumSignificantDigits = 2
        formatter.exponentSymbol = "x10"
        return formatter
    }()

    /// Returns `value` parsed into scientific representation of the form `Ax10^B`, with
    /// a superscript `TextLineSegment` for `B`
    ///
    /// - Note: In the case parsing fails, `value` will be returned to 2 decimal places
    public static func scientific(
        value: CGFloat
    ) -> TextLine {
        guard let (firstPart, secondPart) = scientificComponents(value: value) else {
            return TextLine(value.str(decimals: 2))
        }
        return TextLine("\(firstPart)^\(secondPart)^")
    }

    /// Returns components for a String representation of `value` in the form Ax10^
    public static func scientificComponents(
        value: CGFloat
    ) -> (String, String)? {
        guard let scientificValue = numberFormatter.string(for: value) else {
            return nil
        }
        return parseScientificValue(value: scientificValue)
    }

    public static func scientificString(
        value: CGFloat
    ) -> String {
        numberFormatter.string(for: value) ?? value.str(decimals: 2)
    }

    private static func parseScientificValue(
        value: String
    ) -> (String, String)? {
        guard let xIndex = value.firstIndex(of: "x") else {
            return nil
        }
        let zeroIndex = value.index(xIndex, offsetBy: 2)
        guard zeroIndex < value.endIndex else {
            return nil
        }

        let xToZero = value[xIndex...zeroIndex]
        guard xToZero == "x10" else {
            return nil
        }

        let powerIndex = value.index(after: zeroIndex)
        guard powerIndex < value.endIndex else {
            return nil
        }

        let firstPart = String(value[..<powerIndex])
        let endPart = String(value[powerIndex...])

        return (firstPart, endPart)
    }
}
