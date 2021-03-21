//
// Reactions App
//

import ReactionsCore
import CoreGraphics

class ReactionComponentsWrapper {

    let beakerCols: Int
    var beakerRows: Int {
        didSet {
            if beakerRows != oldValue {
                rowsWasSet(volumeWasIncreased: beakerRows > oldValue)
            }

        }
    }
    var coefficients: BalancedReactionCoefficients {
        didSet {
            setComponents()
        }
    }
    var equilibriumConstant: CGFloat {
        didSet {
            setComponents()
        }
    }

    let startTime: CGFloat
    let equilibriumTime: CGFloat
    let previous: ReactionComponentsWrapper?
    let maxC: CGFloat

    private let gridCols: Int
    private let gridRows: Int

    private(set) var molecules: MoleculeValue<[GridCoordinate]>
    private var gridMolecules: MoleculeValue<[GridCoordinate]>

    init(
        coefficients: BalancedReactionCoefficients,
        equilibriumConstant: CGFloat,
        beakerCols: Int,
        beakerRows: Int,
        maxBeakerRows: Int,
        dynamicGridCols: Int,
        dynamicGridRows: Int,
        startTime: CGFloat,
        equilibriumTime: CGFloat,
        maxC: CGFloat = AqueousReactionSettings.ConcentrationInput.maxInitial
    ) {
        self.beakerCols = beakerCols
        self.beakerRows = beakerRows
        self.coefficients = coefficients
        self.equilibriumConstant = equilibriumConstant
        self.startTime = startTime
        self.equilibriumTime = equilibriumTime
        self.previous = nil
        self.maxC = maxC
        self.gridCols = dynamicGridCols
        self.gridRows = dynamicGridRows

        let emptyCoords = MoleculeValue(builder: { _ in [GridCoordinate]() })

        self.molecules = emptyCoords
        self.gridMolecules = emptyCoords
        self.components = ReactionComponents(
            initialBeakerMolecules: emptyCoords,
            coefficients: coefficients,
            equilibriumConstant: equilibriumConstant,
            shuffledBeakerCoords: GridCoordinate.grid(cols: beakerCols, rows: beakerRows).shuffled(),
            beakerGridSize: beakerCols * beakerRows,
            initialGridMolecules: emptyCoords,
            shuffledEquilibriumGrid: GridCoordinate.grid(cols: dynamicGridCols, rows: dynamicGridRows).shuffled(),
            startTime: startTime,
            equilibriumTime: equilibriumTime,
            previousEquation: nil,
            previousMolecules: nil,
            rowsHaveChangeFromPrevious: nil
        )
    }

    init(
        previous: ReactionComponentsWrapper,
        startTime: CGFloat,
        equilibriumTime: CGFloat
    ) {
        self.beakerCols = previous.beakerCols
        self.beakerRows = previous.beakerRows
        self.coefficients = previous.coefficients
        self.equilibriumConstant = previous.equilibriumConstant
        self.startTime = startTime
        self.equilibriumTime = equilibriumTime
        self.maxC = previous.maxC
        self.previous = previous
        self.gridCols = previous.gridCols
        self.gridRows = previous.gridRows

        let filteredMolecules = Self.consolidate(
            molecules: previous.components.beakerMolecules,
            at: previous.components.equation.equilibriumTime
        )
        self.molecules = filteredMolecules
        let previousGridMolecules = previous.components.equilibriumGrid.map {
            $0.coords(at: previous.equilibriumTime)
        }
        self.gridMolecules = previousGridMolecules
        self.components = ReactionComponents(
            initialBeakerMolecules: filteredMolecules,
            coefficients: previous.coefficients,
            equilibriumConstant: previous.equilibriumConstant,
            shuffledBeakerCoords: previous.components.shuffledBeakerCoords,
            beakerGridSize: previous.beakerGridSize,
            initialGridMolecules: previousGridMolecules,
            shuffledEquilibriumGrid: previous.components.shuffledEquilibriumGrid,
            startTime: startTime,
            equilibriumTime: equilibriumTime,
            previousEquation: previous.components.equation,
            previousMolecules: filteredMolecules,
            rowsHaveChangeFromPrevious: false
        )
    }

    func reset() {
        if let previous = previous {
            molecules = previous.molecules
            gridMolecules = previous.gridMolecules
        } else {
            molecules = MoleculeValue(builder: { _ in [] })
            gridMolecules = MoleculeValue(builder: { _ in [] })
            setComponents()
        }
    }

    func increment(molecule: AqueousMolecule, count: Int) {
        let current = molecules.value(for: molecule)
        let avoid = molecules.all.flatten
        let maxAdd = maximumToAdd(to: current, maxConcentration: maxC)
        let toAdd = min(maxAdd, count)
        guard toAdd > 0 else { return }
        let newCoords = GridCoordinateList.addingRandomElementsTo(
            grid: current,
            count: toAdd,
            cols: beakerCols,
            rows: beakerRows,
            avoiding: avoid
        )
        molecules = molecules.updating(with: newCoords, for: molecule)
        updateGridMolecules(for: molecule)
        setComponents()
    }

    private func updateGridMolecules(for molecule: AqueousMolecule) {
        let updatedGrid = getUpdatedGridMolecule(for: molecule)
        gridMolecules = gridMolecules.updating(with: updatedGrid, for: molecule)
    }

    private func getUpdatedGridMolecule(
        for molecule: AqueousMolecule
    ) -> [GridCoordinate] {
        let targetConcentration = GridUtil.initialConcentration(
            of: molecule,
            coords: molecules.value(for: molecule),
            gridSize: beakerGridSize,
            previousCoords: components.previousMolecules?.value(for: molecule),
            previousEquation: components.previousEquation,
            at: startTime,
            rowsHaveChangeFromPrevious: previous.map { $0.beakerRows != beakerRows }
        )
        let targetCount = (targetConcentration * CGFloat(gridCols * gridRows)).roundedInt()
        let currentGrid = gridMolecules.value(for: molecule)
        let delta = targetCount - currentGrid.count
        if delta < 0 {
            return Array(currentGrid.dropLast(abs(delta)))
        } else {
            return GridCoordinateList.addingRandomElementsTo(
                grid: currentGrid,
                count: delta,
                cols: gridCols,
                rows: gridRows,
                avoiding: gridMolecules.all.flatten
            )
        }
    }

    private(set) var components: ReactionComponents

    private func setComponents() {
        components = ReactionComponents(
            initialBeakerMolecules: molecules,
            coefficients: coefficients,
            equilibriumConstant: equilibriumConstant,
            shuffledBeakerCoords: components.shuffledBeakerCoords,
            beakerGridSize: beakerGridSize,
            initialGridMolecules: gridMolecules,
            shuffledEquilibriumGrid: components.shuffledEquilibriumGrid,
            startTime: startTime,
            equilibriumTime: equilibriumTime,
            previousEquation: components.previousEquation,
            previousMolecules: components.previousMolecules,
            rowsHaveChangeFromPrevious: previous.map { $0.beakerRows != beakerRows }
        )
    }

    private var beakerGridSize: Int {
        beakerCols * beakerRows
    }

    func concentrationIncremented(of molecule: AqueousMolecule) -> CGFloat {
        func getConcentration(from components: ReactionComponents, at time: CGFloat) -> CGFloat {
            let molecules = components.beakerMolecules.first { $0.molecule == molecule }?.animatingMolecules
            let fraction = molecules.map {
                FractionedCoordinates(
                    coordinates: $0.molecules.coords,
                    fractionToDraw: $0.fractionToDraw
                )
            }
            let count = fraction?.coords(at: time).count ?? 0
            return CGFloat(count) / CGFloat(beakerGridSize)
        }

        let currentC = getConcentration(from: components, at: startTime)
        let previousC = previous.map { getConcentration(from: $0.components, at: $0.equilibriumTime) }

        return currentC - (previousC ?? 0)
    }

    private func rowsWasSet(volumeWasIncreased: Bool) {
        if volumeWasIncreased {
            spreadOutMolecules()
        } else {
            AqueousMolecule.allCases.forEach { molecule in
                decreaseVolume(for: molecule)
            }
        }

        setComponents()
    }

    private func spreadOutMolecules() {
        for index in AqueousMolecule.allCases.indices {
            let molecule = AqueousMolecule.allCases[index]
            let current = molecules.value(for: molecule)
            let previousMolecules = AqueousMolecule.allCases[0..<index]
            let previousCoords = previousMolecules.flatMap {
                molecules.value(for: $0)
            }
            let updatedCoords = GridCoordinateList.addingRandomElementsTo(
                grid: [],
                count: current.count,
                cols: beakerCols,
                rows: beakerRows,
                avoiding: previousCoords
            )
            molecules = molecules.updating(with: updatedCoords, for: molecule)
            updateGridMolecules(for: molecule)
        }
    }


    private func decreaseVolume(for molecule: AqueousMolecule) {
        let filteredMolecules = molecules.map { $0.filter { $0.row < beakerRows }}
        let coords = molecules.value(for: molecule)
        let filteredCoords = filteredMolecules.value(for: molecule)
        let numToAdd = coords.count - filteredCoords.count

        guard numToAdd > 0 else { return }
        let updatedCoords = GridCoordinateList.addingRandomElementsTo(
            grid: filteredCoords,
            count: numToAdd,
            cols: beakerCols,
            rows: beakerRows,
            avoiding: filteredMolecules.all.flatten
        )

        molecules = molecules.updating(with: updatedCoords, for: molecule)
        updateGridMolecules(for: molecule)
    }

}

extension ReactionComponentsWrapper {
    func canIncrement(molecule: AqueousMolecule) -> Bool {
        maximumToAdd(
            to: molecules.value(for: molecule),
            maxConcentration: maxC
        ) > 0
    }

    fileprivate func maximumToAdd(
        to existing: [GridCoordinate],
        maxConcentration: CGFloat
    ) -> Int {
        let available = CGFloat(beakerGridSize)
        let maxCount = (maxConcentration * available).roundedInt()
        return maxCount - existing.count
    }
}

extension ReactionComponentsWrapper {
    static func consolidate(
        molecules: [LabelledAnimatingBeakerMolecules],
        at time: CGFloat
    ) -> MoleculeValue<[GridCoordinate]> {
        let fractionedCoords = molecules.map {
            FractionedCoordinates(
                coordinates: $0.animatingMolecules.molecules.coords,
                fractionToDraw: $0.animatingMolecules.fractionToDraw
            )
        }
        let visibleMolecules = fractionedCoords.map {
            $0.coords(at: time)
        }

        var builder = [AqueousMolecule:[GridCoordinate]]()

        for i in 0..<visibleMolecules.count {
            let element = molecules[i].molecule
            let others = Array(visibleMolecules[i+1..<visibleMolecules.count]).flatten
            let current = visibleMolecules[i]
            let filtered = current.filter {
                !others.contains($0)
            }
            builder[element] = filtered
        }
        return MoleculeValue(builder: { builder[$0] ?? [] })
    }
}


struct LabelledAnimatingBeakerMolecules {
    let molecule: AqueousMolecule
    let animatingMolecules: AnimatingBeakerMolecules
}

