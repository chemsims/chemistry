//
// Reactions App
//

import SwiftUI

/// A model to handle adding a reactant to a grid of molecules, which reactants with another reactant to produce a product
public class ReactingBeakerViewModel<Molecule>: ObservableObject where Molecule : CaseIterable, Molecule : Hashable {

    /// Creates a new instance
    ///
    /// - Parameters:
    ///     - initial: The initial beaker molecules
    ///     - cols: Number of beaker columns
    ///     - rows: Number of beaker rows
    public init(
        initial: EnumMap<Molecule, BeakerMolecules>,
        cols: Int = MoleculeGridSettings.cols,
        rows: Int = MoleculeGridSettings.rows
    ) {
        molecules = Molecule.allCases.map { molecule in
            ReactingMolecules(
                finalMolecule: molecule,
                molecules: initial.value(for: molecule)
            )
        }
        self.cols = cols
        self.rows = rows

        var baseIndices = EnumMap<Molecule, Int>.constant(0)

        Molecule.allCases.enumerated().forEach { (index, molecule) in
            baseIndices = baseIndices.updating(with: index, for: molecule)
        }
        self.baseIndices = baseIndices
    }

    /// The molecules to display.
    ///
    /// Note that the size of this array will not be the same as `Molecule.allCases`. If you need access to the
    /// molecules displayed for each molecule type, use the `consolidated` property.
    @Published public var molecules = [ReactingMolecules<Molecule>]()

    private let baseIndices: EnumMap<Molecule, Int>
    private let cols: Int
    private let rows: Int

    /// Adds a reactant to the beaker.
    ///
    /// A new `reactant` molecule will be added at a random position in the grid, and it's color will then change into
    /// the `product` molecule color, over the given `duration`.
    ///
    /// An existing `otherReactant` molecule will be selected, and it's color will also change into the `product` molecule
    /// color, over the given `duration`.
    ///
    /// If there is no more `otherReactant` left in the beaker, then `reactant` will still be added, but will not produce `product`.
    ///
    /// - Parameters:
    ///     - reactant: The reactant to add
    ///     - otherReactant: The other reactant that will also be turned into `product`
    ///     - product: The product molecule to be produced
    ///     - duration: Duration of the reaction
    public func add(
        reactant: Molecule,
        reactingWith otherReactant: Molecule,
        producing product: Molecule,
        withDuration duration: TimeInterval
    ) {
        let otherReactantIndex = baseIndices.value(for: otherReactant)
        guard let otherReactantCoord = molecules[otherReactantIndex].molecules.coords.popLast() else {
            let reactantCoords = molecules[baseIndices.value(for: reactant)].molecules.coords
            molecules[baseIndices.value(for: reactant)].molecules.coords = GridCoordinateList.addingRandomElementsTo(
                grid: reactantCoords,
                count: 1,
                cols: cols,
                rows: rows,
                avoiding: molecules.flatMap { $0.molecules.coords }
            )
            return
        }

        let nextIndex = molecules.endIndex
        molecules.append(
            ReactingMolecules(
                finalMolecule: product,
                molecules: BeakerMolecules(
                    coords: [otherReactantCoord],
                    color: color(of: otherReactant),
                    label: ""
                )
            )
        )

        let reactantGrid = GridCoordinateList.addingRandomElementsTo(
            grid: [],
            count: 1,
            cols: cols,
            rows: rows,
            avoiding: molecules.flatMap { $0.molecules.coords }
        )

        molecules.append(
            ReactingMolecules(
                finalMolecule: product,
                molecules: BeakerMolecules(
                    coords: reactantGrid,
                    color: color(of: reactant),
                    label: ""
                )
            )
        )

        withAnimation(.linear(duration: duration)) {
            molecules[nextIndex].molecules.color = color(of: product)
            molecules[nextIndex + 1].molecules.color = color(of: product)
        }
    }

    /// Returns an `EnumMap` of molecule to the beaker molecules which are displayed
    public var consolidated: EnumMap<Molecule, BeakerMolecules> {
        func beakerMolecules(forMolecule molecule: Molecule) -> BeakerMolecules {
            let coords = molecules.filter { $0.finalMolecule == molecule }.flatMap { $0.molecules.coords }
            return BeakerMolecules(
                coords: coords,
                color: color(of: molecule),
                label: ""
            )
        }

        return EnumMap<Molecule, BeakerMolecules>(builder: beakerMolecules)
    }

    private func color(of molecule: Molecule) -> Color {
        molecules[baseIndices.value(for: molecule)].molecules.color
    }
}

public struct ReactingMolecules<Molecule> {

    public init(
        finalMolecule: Molecule,
        molecules: BeakerMolecules
    ) {
        self.finalMolecule = finalMolecule
        self.molecules = molecules
    }

    public let finalMolecule: Molecule
    public var molecules: BeakerMolecules
}
