//
// Reactions App
//

import Foundation

public struct Strings {
    public static func withNoBreaks(str: String) -> String {
        CogSciKit.StringUtil.withNoBreaks(str: str)
    }

    public static let aVsT: String = withNoBreaks(str: "**([A] vs t)**")
}
