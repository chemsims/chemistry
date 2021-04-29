//
// Reactions App
//


import Foundation

public struct StringUtil {

    private init() { }

    /// Combines strings using commas to separate elements, except the last element which uses 'and'
    ///
    /// ```
    /// // returns "a, b, c and d"
    /// combineStringsWithFinalAnd(["a", "b", "c", "d"])
    /// ```
    public static func combineStringsWithFinalAnd(
        _ elements: [String]
    ) -> String {
        if elements.isEmpty {
            return ""
        } else if elements.count == 1{
            return elements.first!
        }

        let withoutLastElement = elements.dropFirst().dropLast().reduce(elements.first!) {
            $0 + ", \($1)"
        }

        return "\(withoutLastElement) and \(elements.last!)"
    }
}
