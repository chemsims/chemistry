//
// Reactions App
//

import SwiftUI
import ReactionsCore

class PrecipitationComponents: ObservableObject {

    init(
        reaction: PrecipitationReaction,
        rows: Int,
        cols: Int = MoleculeGridSettings.cols,
        volume: CGFloat
    ) {
        let grid = BeakerGrid(rows: rows, cols: cols)
        let settings = Settings()

        self.reaction = reaction
        self.grid = grid
        self.volume = volume
        self.settings = settings
        currentComponents = KnownReactantPreparation.components(
            unknownReactantCoeff: reaction.unknownReactant.coeff,
            grid: grid,
            settings: settings
        )
    }

    static let reactionProgressAtEndOfInitialReaction: CGFloat = 0.5
    static let reactionProgressAtEndOfFinalReaction: CGFloat = 1

    let reaction: PrecipitationReaction
    let grid: BeakerGrid
    let volume: CGFloat

    private let settings: Settings

    var phase: Phase = .addKnownReactant {
        didSet {
            currentComponents = getComponentsForCurrentPhase()
        }
    }

    @Published private var currentComponents: PhaseComponents
    @Published var reactionProgress: CGFloat = 0

    var reactionProgressModel: ReactionProgressChartViewModel<Molecule> {
        .init(
            molecules: .init { molecule in
                .init(
                    label: molecule.name(reaction: reaction),
                    columnIndex: molecule.rawValue,
                    initialCount: 0,
                    color: molecule.color(reaction: reaction)
                )
            },
            settings: .init(),
            timing: .init()
        )
    }

    func coords(for molecule: Molecule) -> FractionedCoordinates {
        currentComponents.coords(for: molecule)
    }

    func add(reactant: Reactant, count: Int) {
        currentComponents.add(reactant: reactant, count: count)
    }

    func canAdd(reactant: Reactant) -> Bool {
        currentComponents.canAdd(reactant: reactant)
    }

    func hasAddedEnough(of reactant: Reactant) -> Bool {
        currentComponents.hasAddedEnough(of: reactant)
    }

    var knownReactantMolarity: CGFloat {
        molarity(of: .knownReactant)
    }

    var knownReactantMoles: CGFloat {
        moles(of: .knownReactant)
    }

    var unknownReactantMass: CGFloat {
        moles(of: .unknownReactant) * CGFloat(reaction.unknownReactant.molarMass)
    }

    var unknownReactantMoles: CGFloat {
        moles(of: .unknownReactant)
    }

    private func moles(of molecule: Molecule) -> CGFloat {
        volume * molarity(of: molecule)
    }

    private func molarity(of molecule: Molecule) -> CGFloat {
        let count = coords(for: molecule).coordinates.count
        return grid.concentration(count: count)
    }

    private func getComponentsForCurrentPhase() -> PhaseComponents {
        switch phase {
        case .addKnownReactant:
            return KnownReactantPreparation.components(
                unknownReactantCoeff: reaction.unknownReactant.coeff,
                grid: grid,
                settings: settings
            )
        case .addUnknownReactant:
            return UnknownReactantPreparation.components(
                unknownReactantCoeff: reaction.unknownReactant.coeff,
                previous: currentComponents,
                grid: grid,
                settings: settings
            )
        }
    }
}


extension PrecipitationComponents {
    enum Phase {
        case addKnownReactant,
             addUnknownReactant
    }
}

extension PrecipitationComponents {
    struct Settings {
        init(
            minConcentrationOfKnownReactantPostFirstReaction: CGFloat = 0.1,
            minConcentrationOfUnknownReactantToReact: CGFloat = 0.1
        ) {
            self.minConcentrationOfKnownReactantPostFirstReaction = minConcentrationOfKnownReactantPostFirstReaction
            self.minConcentrationOfUnknownReactantToReact = minConcentrationOfUnknownReactantToReact
        }
        let minConcentrationOfKnownReactantPostFirstReaction: CGFloat
        let minConcentrationOfUnknownReactantToReact: CGFloat
    }
}

extension PrecipitationComponents {
    enum Reactant: Int, Identifiable, CaseIterable {
        case known, unknown

        var id: Int {
            rawValue
        }

        var molecule: Molecule {
            switch self {
            case .known: return .knownReactant
            case .unknown: return .unknownReactant
            }
        }
    }

    enum Molecule: Int, CaseIterable {
        case knownReactant, unknownReactant, product

        func name(reaction: PrecipitationReaction) -> TextLine {
            switch self {
            case .knownReactant: return reaction.knownReactant.name
            case .unknownReactant: return reaction.unknownReactant.name(showMetal: false)
            case .product: return reaction.product.name
            }
        }

        // TODO, store color on the reaction definition
        func color(reaction: PrecipitationReaction) -> Color {
            switch self {
            case .knownReactant: return .red
            case .unknownReactant: return .blue
            case .product: return .orange
            }
        }
    }
}

protocol PhaseComponents {
    func coords(for molecule: PrecipitationComponents.Molecule) -> FractionedCoordinates

    func canAdd(reactant: PrecipitationComponents.Reactant) -> Bool

    func hasAddedEnough(of reactant: PrecipitationComponents.Reactant) -> Bool

    mutating func add(reactant: PrecipitationComponents.Reactant, count: Int)
}

extension PrecipitationComponents {
    struct KnownReactantPreparation {
        static func components(
            unknownReactantCoeff: Int,
            grid: BeakerGrid,
            settings: PrecipitationComponents.Settings
        ) -> ReactantPreparation {
            let minToAdd = Self.minToAdd(
                unknownReactantCoeff: unknownReactantCoeff,
                grid: grid,
                settings: settings
            )
            let maxToAdd = Self.maxToAdd(
                unknownReactantCoeff: unknownReactantCoeff,
                grid: grid,
                settings: settings
            )
            return ReactantPreparation(
                grid: grid,
                reactant: .known,
                minToAdd: minToAdd,
                maxToAdd: maxToAdd,
                previous: nil
            )
        }

        static func minToAdd(
            unknownReactantCoeff: Int,
            grid: BeakerGrid,
            settings: PrecipitationComponents.Settings
        ) -> Int {
            let minToRemain = grid.count(
                concentration: settings.minConcentrationOfKnownReactantPostFirstReaction
            )
            let minConsumedOtherReactant = grid.count(
                concentration: settings.minConcentrationOfUnknownReactantToReact
            )
            let minConsumed = minConsumedOtherReactant / unknownReactantCoeff
            return minToRemain + minConsumed
        }

        /// Returns max known coords, such that they can all be consumed by adding enough
        /// unknown reactant later.
        static func maxToAdd(
            unknownReactantCoeff: Int,
            grid: BeakerGrid,
            settings: PrecipitationComponents.Settings
        ) -> Int {
            let maxToRemain = grid.size / (1 + unknownReactantCoeff)
            let availableForReaction = grid.size - maxToRemain
            let consumed = availableForReaction / (1 + unknownReactantCoeff)
            return maxToRemain + consumed
        }
    }
}

extension PrecipitationComponents {
    struct UnknownReactantPreparation {
        static func components(
            unknownReactantCoeff: Int,
            previous: PhaseComponents,
            grid: BeakerGrid,
            settings: Settings
        ) -> ReactantPreparation {
            let minToAdd = Self.minToAdd(
                grid: grid,
                settings: settings
            )
            let maxToAdd = Self.maxToAdd(
                unknownReactantCoeff: unknownReactantCoeff,
                knownReactantCount: previous.coords(for: .knownReactant).coordinates.count,
                grid: grid,
                settings: settings
            )
            return ReactantPreparation(
                grid: grid,
                reactant: .unknown,
                minToAdd: minToAdd,
                maxToAdd: maxToAdd,
                previous: previous
            )
        }

        static func minToAdd(
            grid: BeakerGrid,
            settings: PrecipitationComponents.Settings
        ) -> Int {
            grid.count(
                concentration: settings.minConcentrationOfUnknownReactantToReact
            )
        }

        static func maxToAdd(
            unknownReactantCoeff: Int,
            knownReactantCount: Int,
            grid: BeakerGrid,
            settings: PrecipitationComponents.Settings
        ) -> Int {
            let minKnownReactant = grid.count(
                concentration: settings.minConcentrationOfKnownReactantPostFirstReaction
            )
            let maxKnownReactantToConsume = knownReactantCount - minKnownReactant
            return maxKnownReactantToConsume * unknownReactantCoeff
        }
    }
}

extension PrecipitationComponents {
    struct ReactantPreparation: PhaseComponents {
        init(
            grid: BeakerGrid,
            reactant: Reactant,
            minToAdd: Int,
            maxToAdd: Int,
            previous: PhaseComponents?
        ) {
            let otherMolecules = Molecule.allCases.filter { $0 != reactant.molecule}
            let otherCoords = otherMolecules.flatMap { m in
                previous?.coords(for: m).coordinates ?? []
            }
            self.reactant = reactant
            self.previous = previous
            self.underlying = LimitedGridCoords(
                grid: grid,
                otherCoords: otherCoords,
                minToAdd: minToAdd,
                maxToAdd: maxToAdd
            )
        }

        private var underlying: LimitedGridCoords
        private let reactant: Reactant
        @Indirect private var previous: PhaseComponents?

        mutating func add(reactant: PrecipitationComponents.Reactant, count: Int) {
            guard reactant == self.reactant && underlying.canAdd else {
                return
            }
            underlying.add(count: count)
        }

        func coords(for molecule: PrecipitationComponents.Molecule) -> FractionedCoordinates {
            if molecule == reactant.molecule {
                return FractionedCoordinates(
                    coordinates: underlying.coords,
                    fractionToDraw: ConstantEquation(value: 1)
                )
            }
            if let previous = previous {
                return previous.coords(for: molecule)
            }
            return FractionedCoordinates(
                coordinates: [],
                fractionToDraw: ConstantEquation(value: 1)
            )
        }

        func canAdd(reactant: PrecipitationComponents.Reactant) -> Bool {
            reactant == self.reactant && underlying.canAdd
        }

        func hasAddedEnough(of reactant: PrecipitationComponents.Reactant) -> Bool {
            reactant != self.reactant || underlying.hasAddedEnough
        }
    }
}
