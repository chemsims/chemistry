//
// Reactions App
//

import SwiftUI
import ReactionsCore

//class PrecipitationComponents: ObservableObject {
//
//    init(
//        reaction: PrecipitationReaction,
//        rows: Int,
//        cols: Int = MoleculeGridSettings.cols,
//        volume: CGFloat
//    ) {
//        self.precipitate = GrowingPolygon(center: .init(x: 0.5, y: 0.5))
//        let grid = BeakerGrid(rows: rows, cols: cols)
//        let settings = Settings()
//
//        self.reaction = reaction
//        self.grid = grid
//        self.volume = volume
//        self.settings = settings
//        currentComponents = KnownReactantPreparation.components(
//            unknownReactantCoeff: reaction.unknownReactant.coeff,
//            grid: grid,
//            settings: settings,
//            reactionProgressModel: Self.initialReactionProgressModel(reaction: reaction)
//        )
//    }
//
//    static let reactionProgressAtEndOfInitialReaction: CGFloat = 0.5
//    static let reactionProgressAtEndOfFinalReaction: CGFloat = 1
//
//    let reaction: PrecipitationReaction
//    let grid: BeakerGrid
//    let volume: CGFloat
//
//    private let settings: Settings
//
//    var phase: Phase = .addKnownReactant {
//        didSet {
//            currentComponents = getComponentsForCurrentPhase()
//        }
//    }
//
//    @Published private(set) var currentComponents: PhaseComponents
//    @Published var reactionProgress: CGFloat = 0
//    @Published var precipitate: GrowingPolygon
//
//    var reactionProgressModel: ReactionProgressChartViewModel<Molecule> {
//        currentComponents.reactionProgressModel
//    }
//
//    func resetPhase() {
//        if let prev = currentComponents.previous {
//            currentComponents = prev
//        }
//        currentComponents = getComponentsForCurrentPhase()
//    }
//
//    func goBackToPreviousPhase() {
//        if let prev = currentComponents.previous {
//            currentComponents = prev
//        }
//    }
//
//    func runReaction() {
//        reactionProgress = currentComponents.endOfReaction
//        precipitate = precipitate.grow(by: settings.precipitateGrowthMagnitude)
//    }
//
//    // increments end of reaction slightly so that we can animate this change
//    func completeReaction() {
//        reactionProgress = 1.0001 * currentComponents.endOfReaction
//        precipitate = precipitate.grow(exactly: 0.0001)
//    }
//
//    func coords(for molecule: Molecule) -> FractionedCoordinates {
//        currentComponents.coords(for: molecule)
//    }
//
//    func add(reactant: Reactant, count: Int) {
//        currentComponents.add(reactant: reactant, count: count)
//    }
//
//    func canAdd(reactant: Reactant) -> Bool {
//        currentComponents.canAdd(reactant: reactant)
//    }
//
//    func hasAddedEnough(of reactant: Reactant) -> Bool {
//        currentComponents.hasAddedEnough(of: reactant)
//    }
//
//    var knownReactantMolarity: CGFloat {
//        molarity(of: .knownReactant)
//    }
//
//    var knownReactantMoles: CGFloat {
//        moles(of: .knownReactant)
//    }
//
//    var reactingMolesOfUnknownReactant: Equation {
//        let molarity = dynamicMolarity(of: .unknownReactant)
//        let initialMolarity = molarity.getY(at: currentComponents.startOfReaction)
//        let consumedMolarity = initialMolarity - molarity
//        return currentComponents.previouslyReactingUnknownReactantMoles + consumedMolarity
//    }
//
//    var reactingMassOfUnknownReactant: Equation {
//        CGFloat(reaction.unknownReactant.molarMass) * reactingMolesOfUnknownReactant
//    }
//
//    var unknownReactantMass: CGFloat {
//        reactingMassOfUnknownReactant.getY(at: currentComponents.endOfReaction)
//    }
//
//    var unknownReactantMoles: CGFloat {
//        moles(of: .unknownReactant)
//    }
//
//    var productMass: Equation {
//        CGFloat(reaction.product.molarMass) * productMoles
//    }
//
//    var productMoles: Equation {
//        dynamicMoles(of: .product)
//    }
//
//    private func moles(of molecule: Molecule) -> CGFloat {
//        volume * molarity(of: molecule)
//    }
//
//    private func dynamicMoles(of molecule: Molecule) -> Equation {
//        volume * dynamicMolarity(of: molecule)
//    }
//
//    private func dynamicMolarity(of molecule: Molecule) -> Equation {
//        let fractionedCoords = coords(for: molecule)
//        let fraction = fractionedCoords.fractionToDraw
//        let count = CGFloat(fractionedCoords.coordinates.count) * fraction
//        return count / CGFloat(grid.size)
//    }
//
//    private func molarity(of molecule: Molecule) -> CGFloat {
//        let count = coords(for: molecule).coordinates.count
//        return grid.concentration(count: count)
//    }
//
//    private func getComponentsForCurrentPhase() -> PhaseComponents {
//        switch phase {
//        case .addKnownReactant:
//            return KnownReactantPreparation.components(
//                unknownReactantCoeff: reaction.unknownReactant.coeff,
//                grid: grid,
//                settings: settings,
//                reactionProgressModel: Self.initialReactionProgressModel(reaction: reaction)
//            )
//        case .addUnknownReactant:
//            return UnknownReactantPreparation.components(
//                unknownReactantCoeff: reaction.unknownReactant.coeff,
//                previous: currentComponents,
//                grid: grid,
//                settings: settings
//            )
//        case .runReaction:
//            return InitialReaction(
//                unknownReactantCoeff: reaction.unknownReactant.coeff,
//                previous: currentComponents,
//                endOfReaction: Self.reactionProgressAtEndOfInitialReaction,
//                grid: grid
//            )
//        case .addExtraUnknownReactant:
//            return AddExtraUnknownReactant.components(
//                previous: currentComponents,
//                previouslyReactingUnknownReactantMoles: currentComponentsReactingUnknownReactantMoles,
//                unknownReactantCoeff: reaction.unknownReactant.coeff,
//                grid: grid
//            )
//        case .runFinalReaction:
//            return RunFinalReaction(
//                unknownReactantCoeff: reaction.unknownReactant.coeff,
//                startOfReaction: Self.reactionProgressAtEndOfInitialReaction,
//                endOfReaction: Self.reactionProgressAtEndOfFinalReaction,
//                previous: currentComponents,
//                previouslyReactingUnknownReactantMoles: currentComponentsReactingUnknownReactantMoles,
//                grid: grid
//            )
//        }
//    }
//
//    private var currentComponentsReactingUnknownReactantMoles: CGFloat {
//        reactingMolesOfUnknownReactant.getY(at: currentComponents.endOfReaction)
//    }
//
//    static func initialReactionProgressModel(
//        reaction: PrecipitationReaction
//    ) -> ReactionProgressChartViewModel<PrecipitationComponents.Molecule> {
//        .init(
//            molecules: .init { molecule in
//                    .init(
//                        label: molecule.name(reaction: reaction),
//                        columnIndex: molecule.rawValue,
//                        initialCount: 0,
//                        color: molecule.color(reaction: reaction)
//                    )
//            },
//            settings: .init(),
//            timing: .init()
//        )
//    }
//}

extension PrecipitationComponents {

    static func initialReactionProgressModel(
        reaction: PrecipitationReaction
    ) -> ReactionProgressChartViewModel<PrecipitationComponents.Molecule> {
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
}
