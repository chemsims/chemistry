//
// Reactions App
//
  

import Foundation
@testable import reactions_app

extension TextLine: CustomDebugStringConvertible {

    public var debugDescription: String {
        concat(\.debugDescription)
    }

    var plainString: String {
        concat(\.content)
    }

    private func concat(_ getString: KeyPath<TextSegment, String>) -> String {
        content.reduce("") {
            $0 + $1[keyPath: getString]
        }
    }
}

extension TextSegment: CustomDebugStringConvertible {
    public var debugDescription: String {
        "\(em)\(sc)\(content)\(sc)\(em)"
    }

    private var em: String {
        emphasised ? "*" : ""
    }

    private var sc: String {
        switch (scriptType) {
        case .superScript: return "^"
        case .subScript: return "_"
        case nil: return ""
        }
    }
}
