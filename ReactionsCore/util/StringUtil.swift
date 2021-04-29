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
    ///
    /// - Parameter elements: The elements to combine
    public static func combineStringsWithFinalAnd(
        _ elements: [String]
    ) -> String {
        if elements.isEmpty {
            return ""
        } else if elements.count == 1{
            return elements.first!
        }

        let withoutLastElement = combineStrings(elements.dropLast())
        return "\(withoutLastElement) and \(elements.last!)"
    }

    /// Combines strings using commas
    ///
    /// ```
    /// // returns "a, b, c, d"
    /// combineStrings(["a", b", "c", "d"])
    /// ```
    ///
    /// - Parameter elements: The elements to combine
    public static func combineStrings(_ elements: [String]) -> String {
        if elements.isEmpty {
            return ""
        }
        return elements.dropFirst().reduce(elements.first!) {
            $0 + ", \($1)"
        }
    }
}
