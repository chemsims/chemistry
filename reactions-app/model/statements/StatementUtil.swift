//
// Reactions App
//
  

import Foundation

struct Strings {
    static let noBreak = "\u{2060}"

    static func withNoBreaks(str: String) -> String {
        let elements = str.flatMap { c in
            "\(c)\(noBreak)"
        }
        return String(elements)
    }

    static let aVsT: String = withNoBreaks(str: "**([A] vs t)**")
}
