//
// Reactions App
//
  

import Foundation

// TODO - remove ExpressibleByStringLiteral
struct LabelledImage: Equatable, ExpressibleByStringLiteral {
    let image: String
    let label: String

    init(stringLiteral: String) {
        self.image = stringLiteral
        self.label = ""
    }

    init(image: String, label: String) {
        self.image = image
        self.label = label
    }
}
