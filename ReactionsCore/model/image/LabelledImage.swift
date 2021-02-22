//
// Reactions App
//

import Foundation

public struct LabelledImage: Equatable {
    public let image: String
    public let label: String

    public init(image: String, label: String) {
        self.image = image
        self.label = label
    }
}
