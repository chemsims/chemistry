//
// Reactions App
//

import Foundation

struct LabelledImage: Equatable {
    let image: String
    let label: String

    init(image: String, label: String) {
        self.image = image
        self.label = label
    }
}
