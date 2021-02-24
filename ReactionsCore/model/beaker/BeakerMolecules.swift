//
// Reactions App
//


import SwiftUI

public struct BeakerMolecules {
    
    public let coords: [GridCoordinate]
    public let color: Color

    public init(
        coords: [GridCoordinate],
        color: Color
    ) {
        self.coords = coords
        self.color = color
    }
}

public struct AnimatingBeakerMolecules {
    public let molecules: BeakerMolecules
    public let fractionToDraw: Equation

    public init(molecules: BeakerMolecules, fractionToDraw: Equation) {
        self.molecules = molecules
        self.fractionToDraw = fractionToDraw
    }
}
