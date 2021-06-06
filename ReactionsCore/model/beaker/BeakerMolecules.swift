//
// Reactions App
//


import SwiftUI

public struct BeakerMolecules {
    
    public var coords: [GridCoordinate]
    public var color: Color
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
    public var molecules: BeakerMolecules
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
