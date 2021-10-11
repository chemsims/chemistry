//
// Reactions App
//

import CoreGraphics
import ReactionsCore

class PrecipitationComponents: ObservableObject {

    typealias ReactionProgressModel = ReactionProgressChartViewModel<Molecule>

    init(
        reaction: PrecipitationReaction,
        rows: Int,
        cols: Int = MoleculeGridSettings.cols,
        volume: CGFloat,
        settings: Settings = .init()
    ) {
        let grid = BeakerGrid(rows: rows, cols: cols)

        self.reaction = reaction
        self.volume = volume
        self.grid = grid
        self.settings = settings
        self.knownReactantPrep = KnownReactantPreparation(
            unknownReactantCoeff: reaction.unknownReactant.coeff,
            grid: grid,
            reactionProgressModel: Self.initialReactionProgressModel(reaction: reaction),
            settings: settings
        )
        self.precipitate2 = GrowingPolygon(
            center: CGPoint(x: 0.5, y: 0.5),
            steps: 4,
            points: 7,
            pointGrowth: 0.23..<0.48
        )
    }

    let endOfInitialReaction: CGFloat = 0.5
    let endOfFinalReaction: CGFloat = 1

    let reaction: PrecipitationReaction
    let volume: CGFloat
    let grid: BeakerGrid
    let settings: Settings

    let precipitate2: GrowingPolygon

    @Published private(set) var reactionProgress: CGFloat = 0
    @Published private(set) var phase = PrecipitationComponents.Phase.addKnownReactant

    @Published private(set) var knownReactantPrep: KnownReactantPreparation
    @Published private(set) var unknownReactantPrep: UnknownReactantPreparation? = nil
    @Published private(set) var extraUnknownReactantPrep: ExtraUnknownReactantPreparation? = nil
    @Published private(set) var initialReaction: InitialReaction? = nil
    @Published private(set) var finalReaction: FinalReaction? = nil

    func coords(for molecule: Molecule) -> FractionedCoordinates {
        switch phase {
        case .addKnownReactant, .addUnknownReactant, .addExtraUnknownReactant:
            return reactantPrepCoords(for: molecule)
        case .runReaction, .runFinalReaction:
            return reactionCoords(for: molecule)
        }
    }

    private func reactantPrepCoords(for molecule: Molecule) -> FractionedCoordinates {
        guard let currentReactantPrep = currentReactantPrep  else {
            return emptyFractionedCoords
        }

        return FractionedCoordinates(
            coordinates: currentReactantPrep.initialCoords(for: molecule),
            fractionToDraw: ConstantEquation(value: 1)
        )
    }

    private func reactionCoords(
        for molecule: Molecule
    ) -> FractionedCoordinates {
        guard let currentReaction = currentReaction else {
            return emptyFractionedCoords
        }

        let initial = currentReaction.initialCoords(for: molecule)
        let final = currentReaction.finalCoords(for: molecule)

        return FractionedCoordinates(
            initial: initial,
            final: final,
            startOfReaction: startOfReaction,
            endOfReaction: endOfReaction
        )
    }

    private var emptyFractionedCoords: FractionedCoordinates {
        FractionedCoordinates(
            coordinates: [],
            fractionToDraw: ConstantEquation(value: 0)
        )
    }

    func add(reactant: Reactant, count: Int) {
        switch phase {
        case .addKnownReactant:
            knownReactantPrep.add(reactant: reactant, count: count)
        case .addUnknownReactant:
            unknownReactantPrep?.add(reactant: reactant, count: count)
        case .addExtraUnknownReactant:
            extraUnknownReactantPrep?.add(reactant: reactant, count: count)
        default: break
        }
    }

    func canAdd(reactant: Reactant) -> Bool {
        currentReactantPrep?.canAdd(reactant: reactant) ?? false
    }

    func hasAddedEnough(of reactant: Reactant) -> Bool {
        currentReactantPrep?.hasAddedEnough(of: reactant) ?? true
    }

    private var currentReaction: PrecipitationComponentsReaction? {
        switch phase {
        case .runReaction: return initialReaction
        case .runFinalReaction: return finalReaction
        default: return nil
        }
    }

    private var currentReactantPrep: PrecipitationComponentsReactantPreparation? {
        switch phase {
        case .addKnownReactant: return knownReactantPrep
        case .addUnknownReactant: return unknownReactantPrep
        case .addExtraUnknownReactant: return extraUnknownReactantPrep
        default: return nil
        }
    }

    private var startOfReaction: CGFloat {
        switch phase {
        case .addKnownReactant, .addUnknownReactant, .runReaction:
            return 0
        default:
            return endOfInitialReaction
        }
    }

    private var endOfReaction: CGFloat {
        switch phase {
        case .addKnownReactant, .addUnknownReactant, .runReaction:
            return endOfInitialReaction
        default:
            return endOfFinalReaction
        }
    }

    var reactionProgressModel: ReactionProgressChartViewModel<Molecule> {
        reactionProgressModelOpt ?? Self.initialReactionProgressModel(reaction: reaction)
    }

    private var reactionProgressModelOpt: ReactionProgressChartViewModel<Molecule>? {
        switch phase {
        case .addKnownReactant: return knownReactantPrep.reactionProgressModel
        case .addUnknownReactant: return unknownReactantPrep?.reactionProgressModel
        case .runReaction: return initialReaction?.reactionProgressModel
        case .addExtraUnknownReactant: return extraUnknownReactantPrep?.reactionProgressModel
        case .runFinalReaction: return finalReaction?.reactionProgressModel
        }
    }
}

extension PrecipitationComponents {

    func resetPhase() {
        goNextTo(phase: phase)
    }

    func goNextTo(phase newPhase: PrecipitationComponents.Phase) {
        self.phase = newPhase
        switch newPhase {
        case .addKnownReactant:
            setKnownReactantComponents()
        case .addUnknownReactant:
            setUnknownReactantComponents()
        case .runReaction:
            setInitialReactionComponents()
        case .addExtraUnknownReactant:
            setExtraUnknownReactantPrep()
        case .runFinalReaction:
            setFinalReactionComponents()
        }
    }

    func goToPreviousPhase() {
        guard let currentIndex = Phase.allCases.firstIndex(of: phase) else {
            return
        }
        if currentIndex > 0 {
            let previousPhase = Phase.allCases[currentIndex - 1]
            goBackTo(phase: previousPhase)
        }
    }

    func goBackTo(phase newPhase: PrecipitationComponents.Phase) {
        self.phase = newPhase
    }
}

extension PrecipitationComponents {

    var knownReactantInitialMolarity: CGFloat {
        let coords = knownReactantPrep.initialCoords(for: .knownReactant)
        return grid.concentration(count: coords.count)
    }

    var knownReactantInitialMoles: CGFloat {
        volume * knownReactantInitialMolarity
    }

    var productMassProduced: Equation {
        let molarMass = CGFloat(reaction.product.molarMass)
        return molarMass * productMolesProduced
    }

    var productMolesProduced: Equation {
        let coeff = CGFloat(reaction.unknownReactant.coeff)
        return coeff * reactingUnknownReactantMoles
    }

    var unknownReactantMassAdded: CGFloat {
        var totalMass: CGFloat = 0
        if phase >= .addUnknownReactant {
            totalMass += firstReactionReactantMassAdded
        }
        if phase >= .addExtraUnknownReactant {
            totalMass += secondReactionReactantMassAdded
        }
        return totalMass
    }

    var unknownReactantMolesAdded: CGFloat {
        unknownReactantMassAdded / CGFloat(reaction.unknownReactant.molarMass)
    }

    private var firstReactionReactantMassAdded: CGFloat {
        guard let unknownReactantPrep = unknownReactantPrep else {
            return 0
        }
        return unknownReactantMassAdded(model: unknownReactantPrep)
    }

    private var secondReactionReactantMassAdded: CGFloat {
        guard let extraUnknownReactantPrep = extraUnknownReactantPrep else {
            return 0
        }
        return unknownReactantMassAdded(model: extraUnknownReactantPrep)
    }

    private func unknownReactantMassAdded(
        model: PrecipitationComponentsReactantPreparation
    ) -> CGFloat {
        let count = model.initialCoords(for: .unknownReactant).count
        let concentration = grid.concentration(count: count)
        let moles = volume * concentration
        let molarMass = CGFloat(reaction.unknownReactant.molarMass)
        return molarMass * moles
    }

    var reactingUnknownReactantMoles: Equation {
        reactingUnknownReactantMass / CGFloat(reaction.unknownReactant.molarMass)
    }

    var reactingUnknownReactantMass: Equation {
        let lhs = LinearEquation(
            x1: 0,
            y1: 0,
            x2: endOfInitialReaction,
            y2: firstReactionReactantMassAdded
        )
        let rhs: Equation
        if phase >= .addExtraUnknownReactant {
            rhs = LinearEquation(
                x1: endOfInitialReaction,
                y1: firstReactionReactantMassAdded,
                x2: endOfFinalReaction,
                y2: firstReactionReactantMassAdded + secondReactionReactantMassAdded
            )
        } else {
            rhs = ConstantEquation(value: firstReactionReactantMassAdded)
        }

        return SwitchingEquation(
            thresholdX: endOfInitialReaction,
            underlyingLeft: lhs,
            underlyingRight: rhs
        )
    }
}

extension PrecipitationComponents {
    func runReaction() {
        reactionProgress = endOfReaction
    }

    func completeReaction() {
        reactionProgress = 1.0001 * endOfReaction
        runAllReactionProgressReactions()
    }

    func resetReaction() {
        reactionProgress = startOfReaction
        resetPhase()
    }

    func runOneReactionProgressReaction() {
        currentReaction?.runOneReactionProgressReaction()
    }

    private func runAllReactionProgressReactions() {
        currentReaction?.runAllReactionProgressReactions(duration: 0.5)
    }

    var reactionsToRun: Int {
        currentReaction?.reactionsToRun ?? 0
    }
}

extension PrecipitationComponents {
    private func setKnownReactantComponents() {
        self.knownReactantPrep = KnownReactantPreparation(
            unknownReactantCoeff: reaction.unknownReactant.coeff,
            grid: grid,
            reactionProgressModel: Self.initialReactionProgressModel(reaction: reaction),
            settings: settings
        )
    }

    private func setUnknownReactantComponents() {
        self.unknownReactantPrep = UnknownReactantPreparation(
            unknownReactantCoeff: reaction.unknownReactant.coeff,
            previous: knownReactantPrep,
            grid: grid,
            settings: settings
        )
    }

    private func setInitialReactionComponents() {
        guard let unknownReactantPrep = unknownReactantPrep else {
            return
        }
        self.initialReaction = InitialReaction(
            unknownReactantCoeff: reaction.unknownReactant.coeff,
            previous: unknownReactantPrep,
            grid: grid
        )
    }

    private func setExtraUnknownReactantPrep() {
        guard let initialReaction = initialReaction else {
            return
        }
        self.extraUnknownReactantPrep = ExtraUnknownReactantPreparation(
            previous: initialReaction,
            unknownReactantCoeff: reaction.unknownReactant.coeff,
            grid: grid,
            settings: settings
        )
    }

    private func setFinalReactionComponents() {
        guard let extraReactantPrep = extraUnknownReactantPrep else {
            return
        }
        self.finalReaction = .init(
            unknownReactantCoeff: reaction.unknownReactant.coeff,
            startOfReaction: endOfInitialReaction,
            previous: extraReactantPrep,
            previouslyReactingUnknownReactantMoles: 0,
            grid: grid
        )
    }
}

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
