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
                initialMolecule: molecule,
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
    /// - Note: If there is no more `otherReactant` left in the beaker, the method will return with no effect.
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
            print("No more \(otherReactant) to react with")
            return
        }

        let nextIndex = molecules.endIndex
        molecules.append(
            ReactingMolecules(
                initialMolecule: otherReactant,
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
                initialMolecule: reactant,
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

    private func color(of molecule: Molecule) -> Color {
        molecules[baseIndices.value(for: molecule)].molecules.color
    }
}

public struct ReactingMolecules<Molecule> {

    public init(
        initialMolecule: Molecule,
        molecules: BeakerMolecules
    ) {
        self.initialMolecule = initialMolecule
        self.molecules = molecules
    }

    let initialMolecule: Molecule
    var molecules: BeakerMolecules
}
