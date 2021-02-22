//
// Reactions App
//

import Foundation

public struct Strings {
    public static let noBreak = "\u{2060}"

    public static func withNoBreaks(str: String) -> String {
        let elements = str.flatMap { c in
            "\(c)\(noBreak)"
        }
        return String(elements)
    }

    public static let aVsT: String = withNoBreaks(str: "**([A] vs t)**")
}
