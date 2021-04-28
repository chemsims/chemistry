//
// Reactions App
//


import SwiftUI

public struct BeakerMolecules {
    
    public let coords: [GridCoordinate]
    public let color: Color
    public let label: String

    public init(
        coords: [GridCoordinate],
        color: Color,
        label: String
    ) {
        self.coords = coords
        self.color = color
        self.label = label
    }
}

public struct AnimatingBeakerMolecules {
    public let molecules: BeakerMolecules
    public let fractionToDraw: Equation

    public init(molecules: BeakerMolecules, fractionToDraw: Equation) {
        self.molecules = molecules
        self.fractionToDraw = fractionToDraw
    }

    public var fractioned: FractionedCoordinates {
        FractionedCoordinates(
            coordinates: molecules.coords,
            fractionToDraw: fractionToDraw
        )
    }
}
