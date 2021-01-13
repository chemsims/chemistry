//
// Reactions App
//
  

import Foundation
@testable import reactions_app

extension TextLine: CustomDebugStringConvertible {
    public var debugDescription: String {
        content.reduce("") {
            $0 + "\n\n" + $1.debugDescription
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
