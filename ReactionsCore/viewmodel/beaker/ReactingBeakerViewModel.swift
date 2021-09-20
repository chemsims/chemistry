//
// Reactions App
//

import SwiftUI

/// A model to handle adding a reactant to a grid of molecules, which reactants with another reactant to produce a product
public class ReactingBeakerViewModel<Molecule>: ObservableObject where Molecule : CaseIterable, Molecule : Hashable {

    /// Creates a new instance
    ///
    /// - Parameters:
    ///   - initial: The initial beaker molecules
    ///   - cols: Number of beaker columns
    ///   - rows: Number of beaker rows
    public init(
        initial: EnumMap<Molecule, BeakerMolecules>,
        cols: Int,
        rows: Int,
        accessibilityLabel: @escaping (Molecule) -> String
    ) {
        molecules = Molecule.allCases.map { molecule in
            ReactingMolecules(
                finalMolecule: molecule,
                molecules: initial.value(for: molecule)
            )
        }
        self.accessibilityLabel = accessibilityLabel
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

    public let accessibilityLabel: (Molecule) -> String

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
    ///   - reactant: The reactant to add
    ///   - consumedReactant: The other reactant that will also be turned into `product`
    ///   - product: The product molecule to be produced
    ///   - duration: Duration of the reaction
    ///   - count: How many `reactant` molecules to add. If this is greater than the available `otherReactant`
    ///     molecules, then additional `reactant` molecules will be added
    ///   - minConsumableReactantCoords: Minimum number of `consumedReactant` which should remain after the
    ///     reaction. Note that the number of `consumedReactant` coords may already be less than this value, in which
    ///     case all of `count` is added as `reactant`.
    public func add(
        reactant: Molecule,
        reactingWith consumedReactant: Molecule,
        producing product: Molecule,
        withDuration duration: TimeInterval,
        count: Int = 1,
        minConsumableReactantCoords: Int = 0
    ) {
        let consumedReactantIndex = baseIndices.value(for: consumedReactant)
        let consumedReactantCurrentCoords = molecules[consumedReactantIndex].molecules.coords

        let availableToConsume = consumedReactantCurrentCoords.count - minConsumableReactantCoords
        let coordCountToConsume = max(0, min(count, availableToConsume))
        let surplusCount = count - coordCountToConsume

        if surplusCount > 0 {
            addDirectly(molecule: reactant, count: surplusCount)
        }

        if coordCountToConsume <= 0 {
            return
        }

        let consumedCoords = Array(consumedReactantCurrentCoords.suffix(coordCountToConsume))
        molecules[consumedReactantIndex].molecules.coords.removeLast(coordCountToConsume)


        let nextIndex = molecules.endIndex
        molecules.append(
            ReactingMolecules(
                finalMolecule: product,
                molecules: BeakerMolecules(
                    coords: consumedCoords,
                    color: color(of: consumedReactant),
                    label: accessibilityLabel(product)
                )
            )
        )

        let reactantGrid = GridCoordinateList.addingRandomElementsTo(
            grid: [],
            count: coordCountToConsume,
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
                    label: accessibilityLabel(product)
                )
            )
        )

        withAnimation(.linear(duration: duration)) {
            molecules[nextIndex].molecules.color = color(of: product)
            molecules[nextIndex + 1].molecules.color = color(of: product)
        }
    }

    /// Adds `molecule` directly to the beaker, with no reaction taking place.
    ///
    /// - Parameters:
    ///   - molecule: The molecule to add
    ///   - count: Number of molecules to add
    public func addDirectly(
        molecule: Molecule,
        count: Int
    ) {
        let index = baseIndices.value(for: molecule)
        let currentCoords = molecules[index].molecules.coords
        molecules[index].molecules.coords = GridCoordinateList.addingRandomElementsTo(
            grid: currentCoords,
            count: count,
            cols: cols,
            rows: rows,
            avoiding: molecules.flatMap { $0.molecules.coords }
        )
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
