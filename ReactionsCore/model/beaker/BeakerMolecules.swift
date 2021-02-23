//
// Reactions App
//


import SwiftUI

public struct BeakerMolecules {
    
    public let coords: [GridCoordinate]
    public let color: Color

    public init(coords: [GridCoordinate], color: Color) {
        self.coords = coords
        self.color = color
    }
}
