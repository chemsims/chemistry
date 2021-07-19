//
// Reactions App
//

import SwiftUI

public class ReactionProgressChartViewModel<MoleculeType : EnumMappable>: ObservableObject {

    public init(
        molecules: EnumMap<MoleculeType, MoleculeDefinition>,
        settings: Settings,
        timing: Timing
    ) {
        self.definitions = molecules
        self.settings = settings

        self.timing = timing

        let moleculeMap = EnumMap<MoleculeType, [Molecule]>(builder: { type in
            let definition = molecules.value(for: type)
            guard definition.initialCount > 0 else {
                return []
            }
            return (0..<definition.initialCount).map { row in
                Molecule(
                    id: UUID(),
                    type: type,
                    definition: definition,
                    rowIndex: row,
                    scale: 1,
                    opacity: 1,
                    willMoveDownToTopOfColumn: false
                )
            }
        })

        self.molecules = moleculeMap.all.flatten
    }

    @Published var molecules: [Molecule]
    public let settings: Settings
    let timing: Timing

    weak var delegate: ReactionProgressChartViewModelDelegate<MoleculeType>?

    let definitions: EnumMap<MoleculeType, MoleculeDefinition>

    private var pendingRemovals = [MoleculeType : Int]()

    private var runningReactions = [ActionSequence]()

    func getMolecules(ofType type: MoleculeType) -> [Molecule] {
        molecules.filter { $0.type == type }
    }
}

// MARK: API
extension ReactionProgressChartViewModel {

    /// Triggers a reaction which adds a molecule of type `addedMolecule`, which then reacts with a `consumedMolecule` type to produce
    /// a molecule of type `producedMolecule`.
    ///
    /// - Returns: True if the reaction was started, or false if the reaction could not be started. Running the reaction
    /// may fail when there are no more molecules of type `consumedMolecule` for example, or if the column of
    /// `molecule` or `producedMolecule` are already full.
    public func startReaction(
        adding addedMolecule: MoleculeType,
        reactsWith consumedMolecule: MoleculeType,
        producing producedMolecule: MoleculeType
    ) -> Bool {
        let reaction = ActionSequence.reaction(added: addedMolecule, consumed: consumedMolecule, produced: producedMolecule)
        return triggerSequence(reaction)
    }

    public func startReaction(
        adding addedMolecule: MoleculeType,
        reactsWith consumedMolecule: MoleculeType
    ) -> Bool {
        let reaction = ActionSequence.reaction(
            added: addedMolecule,
            consumed: consumedMolecule
        )
        return triggerSequence(reaction)
    }

    /// Triggers a reaction which consumes a molecule of type `consumedMolecule`, and produces molecules
    /// of type `producedMolecule`.
    ///
    /// - Returns: True if the reaction was started, or false if it could not be started.
    public func startReactionFromExisting(
        consuming consumedMolecule: MoleculeType,
        producing producedMolecules: [MoleculeType]
    ) -> Bool {
        let reaction = ActionSequence.reactionFromExisting(consumed: consumedMolecule, produced: producedMolecules)
        return triggerSequence(reaction)
    }

    /// Triggers a reaction which consumes a molecule of type `consumedMolecule`.
    ///
    /// - Returns true if the reaction was started, or false if it could not be started
    public func consume(_ consumedMolecule: MoleculeType) -> Bool {
        let reaction = ActionSequence.consume(molecule: consumedMolecule)
        return triggerSequence(reaction)
    }

    /// Schedules adding multiple molecules over the given duration.
    ///
    /// - Returns: True if all of the reactions were triggers, otherwise false. Note that the reactions will be triggered
    /// until the first one fails to trigger. This means any reactions will run, prior to the first reaction which was triggered.
    /// Therefore the provided `count` is not guaranteed to run, in case there is not enough capacity in the column
    /// for example.
    public func addMolecules(_ type: MoleculeType, count: Int, duration: TimeInterval) -> Bool {
        precondition(count > 0, "Count must be above zero")
        let dt = count == 1 ? 0 : duration / Double(count - 1)

        var didTriggerAll = true

        (0..<count).forEach { i in
            let reactionWithDelay = ActionSequence.addMolecules(added: type, delay: Double(i) * dt)
            let didTrigger = triggerSequence(reactionWithDelay)
            if !didTrigger {
                didTriggerAll = false
            }
        }
        return didTriggerAll
    }

    /// Triggers adding a molecule of type `type`.
    ///
    /// - Returns: True if the molecule was added, or false if the molecule could not be added. Adding a molecule will fail
    /// if the column is already full.
    public func addMolecule(_ type: MoleculeType) -> Bool {
        let sequence = ActionSequence.addMolecules(added: type)
        return triggerSequence(sequence)
    }

    /// Returns the total count of molecules of type `type`, taking into actions which are in-flight
    public func moleculeCounts(ofType type: MoleculeType) -> Int {
        let currentMolecules = getMolecules(ofType: type)
        let pendingAdds = runningReactions.filter { $0.willAddMolecule(ofType: type) }.count
        let pendingRemovals = runningReactions.filter { $0.willRemoveMolecule(ofType: type) }.count

        return currentMolecules.count + pendingAdds - pendingRemovals
    }

    /// Returns a new instance with the same molecule count as the current instance.
    ///
    /// Any molecule actions in-flight will not complete with any animations, however, the
    /// new initial counts of molecules will account for the in-flight actions.
    public func copy() -> ReactionProgressChartViewModel<MoleculeType> {
        copy(withCounts: .init(builder: moleculeCounts))
    }

    /// Returns a new instance, using `newCounts` for the molecule counts.
    public func copy(withCounts newCounts: EnumMap<MoleculeType, Int>) -> ReactionProgressChartViewModel<MoleculeType> {
        .init(
            molecules: .init {
                definitions.value(for: $0).withInitialCount(newCounts.value(for: $0))
            },
            settings: settings,
            timing: timing
        )
    }
}

// MARK: Trigger actions
extension ReactionProgressChartViewModel {

    /// Triggers the `sequence`, returning true if it could be triggered, or false if it was not triggered
    private func triggerSequence(_ sequence: ActionSequence) -> Bool {
        guard canPerform(reaction: sequence) else {
            return false
        }
        runningReactions.append(sequence)
        runNextReactionAction(withId: sequence.id)
        return true
    }

    private func runNextReactionAction(
        withId id: UUID
    ) {
        guard let index = runningReactions.firstIndex(where: { $0.id == id }) else {
            return
        }

        if runningReactions[index].pendingActions.isEmpty {
            runningReactions.remove(at: index)
            return
        }

        let action = runningReactions[index].pendingActions.removeFirst()
        let actionDurationTimeInterval = runAction(action)
        let actionDurationMillis = Int(actionDurationTimeInterval * 1000)
        if actionDurationTimeInterval > 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(actionDurationMillis)) { [weak self] in
                self?.runNextReactionAction(withId: id)
            }
        } else {
            runNextReactionAction(withId: id)
        }
    }

    /// Runs the provided `action` and returns how long the action will take
    private func runAction(
        _ action: ReactionAction
    ) -> TimeInterval {
        switch action {
        case let .wait(delay): return delay
        case let .prepareMoleculeForDropping(type: type, id: id):
            return prepareMoleculeForDropping(type, id: id)
        case let .moveMoleculeToTopOfColumn(id: id):
            return moveMoleculeToTopOfColumn(withId: id)
        case let .fadeOutBottomMolecules(types: types):
            return fadeOutBottomMolecules(ofTypes: types)
        case let .deleteBottomMolecules(types: types):
            removeBottomMolecules(ofTypes: types)
            return 0
        case let .slideColumnsDown(types):
            return slideColumnsDown(ofTypes: types)
        case let .addMolecule(types):
            return addMoleculeToTopOfColumn(ofTypes: types)
        }
    }
}

// MARK: Reaction validation
extension ReactionProgressChartViewModel {
    private func canPerform(
        reaction: ActionSequence
    ) -> Bool {
        reaction.added.allSatisfy(canAdd) && reaction.consumed.allSatisfy(canConsume)
    }

    private func canAdd(_ moleculeType: MoleculeType) -> Bool {
        moleculeCounts(ofType: moleculeType) < settings.maxRowIndex + 1
    }

    private func canConsume(_ moleculeType: MoleculeType) -> Bool {
        moleculeCounts(ofType: moleculeType) > 0
    }
}

// MARK: Actions
extension ReactionProgressChartViewModel {

    private func prepareMoleculeForDropping(
        _ type: MoleculeType,
        id: UUID
    ) -> TimeInterval {
        let newMolecule = Molecule(
            id: id,
            type: type,
            definition: definitions.value(for: type),
            rowIndex: settings.maxRowIndex,
            scale: 0,
            opacity: 0,
            willMoveDownToTopOfColumn: true
        )

        let newMoleculeIndex = molecules.endIndex
        molecules.append(newMolecule)

        withAnimation(.linear(duration: timing.fadeDuration)) {
            molecules[newMoleculeIndex].scale = 1
            molecules[newMoleculeIndex].opacity = 1
        }

        return timing.fadeDuration
    }

    /// Moves the molecule with id `id` to the top of the column containing molecules of that type
    private func moveMoleculeToTopOfColumn(
        withId id: UUID
    ) -> TimeInterval {
        guard let index = moleculeIndex(withId: id) else {
            return 0
        }
        delegate?.willMoveMoleculeToTopOfColumn(withId: id)

        let molecule = molecules[index]
        let currentMolecules = getMolecules(ofType: molecule.type)
        let currentMaxIndex = currentMolecules.filter { !$0.willMoveDownToTopOfColumn
        }.map(\.rowIndex).max() ?? -1

        let newMoleculeIndex = currentMaxIndex + 1

        molecules[index].willMoveDownToTopOfColumn = false
        molecules[index].droppedFromRow = molecules[index].rowIndex
        molecules[index].startOfDrop = Date()

        let moveDuration = settings.moveDuration(
            from: molecule.rowIndex,
            to: newMoleculeIndex,
            moveSpeed: timing.dropSpeed
        )
        
        withAnimation(.easeIn(duration: moveDuration)) {
            molecules[index].rowIndex = newMoleculeIndex
        }

        return moveDuration
    }

    /// Fades out the bottom molecule for each column with a matching molecule type
    private func fadeOutBottomMolecules(
        ofTypes types: [MoleculeType]
    ) -> TimeInterval {
        delegate?.willFadeOutBottomMolecules(ofTypes: types)

        func getFirstIndex(_ type: MoleculeType) -> Int? {
            self.molecules.firstIndex { $0.type == type && $0.rowIndex == 0 }
        }

        var ids = [UUID]()
        withAnimation(.linear(duration: timing.fadeDuration)) {
            types.forEach { type in
                if let index = getFirstIndex(type) {
                    ids.append(self.molecules[index].id)
                    self.molecules[index].opacity = 0
                }
            }
        }

        return timing.fadeDuration
    }

    /// Immediately removes any molecules matching `types` which are on the bottom row
    private func removeBottomMolecules(ofTypes types: [MoleculeType]) {
        molecules.removeAll { molecule in
            types.contains(molecule.type) && molecule.rowIndex == 0
        }
    }


    /// Slides all molecules down in the column containing `molecule`, so that there is no gap between the bottom
    /// molecule and the bottom of the chart
    private func slideColumnsDown(
        ofTypes types: [MoleculeType]
    ) -> TimeInterval {
        delegate?.willSlideColumnsDown(ofTypes: types)

        let duration = settings.moveDuration(
            from: 1,
            to: 0,
            moveSpeed: timing.dropSpeed
        )

        // First animate molecules which are still in transit
        var moleculesInTransit = Set<UUID>()
        for index in molecules.indices {
            let molecule = molecules[index]
            if types.contains(molecule.type) {
                if let dropDuration = molecule.durationToMoveToNewTarget(
                    to: molecule.rowIndex - 1,
                    timing: timing,
                    settings: settings
                ) {
                    moleculesInTransit.insert(molecule.id)
                    withAnimation(.linear(duration: dropDuration)) {
                        molecules[index].rowIndex -= 1
                    }
                }
            }
        }

        // Then animate the rest of the molecules in the column in 1 go
        withAnimation(.linear(duration: duration)) {
            for index in molecules.indices {
                let molecule = molecules[index]
                if types.contains(molecule.type) && !moleculesInTransit.contains(molecule.id) {
                    molecules[index].rowIndex -= 1
                }
            }
        }

        return duration
    }

    /// Adds a molecule of type `type` to the top of the column containing that type
    private func addMoleculeToTopOfColumn(ofTypes types: [MoleculeType]) -> TimeInterval {
        delegate?.willAddMoleculeToTopOfColumn(ofTypes: types)

        let createdIds = types.map(addMoleculeToTopOfColumn)
        withAnimation(.linear(duration: timing.fadeDuration)) {
            createdIds.forEach { id in
                if let index = moleculeIndex(withId: id) {
                    molecules[index].opacity = 1
                    molecules[index].scale = 1
                }
            }
        }

        return timing.fadeDuration
    }

    private func addMoleculeToTopOfColumn(ofType type: MoleculeType) -> UUID {
        let currentMolecules = getMolecules(ofType: type)
        let maxRowIndex = currentMolecules.map(\.rowIndex).max() ?? -1
        let nextRowIndex = maxRowIndex + 1

        let newMolecule = Molecule(
            id: UUID(),
            type: type,
            definition: definitions.value(for: type),
            rowIndex: nextRowIndex,
            scale: 0,
            opacity: 0,
            willMoveDownToTopOfColumn: false
        )
        molecules.append(newMolecule)
        return newMolecule.id
    }

    private func moleculeIndex(withId id: UUID) -> Int? {
        molecules.firstIndex { $0.id == id }
    }
}

// MARK: Data types
extension ReactionProgressChartViewModel {
    struct Molecule: Identifiable {
        let id: UUID
        let type: MoleculeType
        let definition: MoleculeDefinition
        var rowIndex: Int
        var scale: CGFloat
        var opacity: Double

        fileprivate var willMoveDownToTopOfColumn: Bool

        /// The time that the molecule was dropped
        fileprivate var startOfDrop: Date?

        /// The row that the molecule was dropped from
        fileprivate var droppedFromRow: Int?

        /// Returns a duration to move the molecule from it's current estimated
        /// position to a new row.
        fileprivate func durationToMoveToNewTarget(
            to newTarget: Int,
            timing: ReactionProgressChartViewModel.Timing,
            settings: ReactionProgressChartViewModel.Settings
        ) -> Double? {
            guard let currentRow = currentEstimatedRow(timing: timing) else {
                return nil
            }
            guard newTarget < rowIndex else {
                return nil
            }

            return settings.moveDuration(
                from: currentRow,
                to: Double(newTarget),
                moveSpeed: timing.dropSpeed
            )
        }

        /// Returns the estimated row for a molecule which is still in transit after being dropped.
        /// This does not apply to molecules where the entire column is shifted down.
        fileprivate func currentEstimatedRow(
            timing: ReactionProgressChartViewModel.Timing
        ) -> Double? {
            guard
                let start = startOfDrop, let from = droppedFromRow else {
                return nil
            }

            let elapsedSeconds = Date().timeIntervalSince(start)

            let rowsMoved = timing.dropSpeed * elapsedSeconds
            let currentRows = Double(from) - rowsMoved
            if currentRows <= Double(rowIndex) {
                return nil
            }

            return currentRows
        }

        func position(
            using geometry: ReactionProgressChartGeometry<MoleculeType>
        ) -> CGPoint {
            geometry.position(colIndex: definition.columnIndex, rowIndex: rowIndex)
        }
    }

    public struct MoleculeDefinition {
        public init(label: TextLine, columnIndex: Int, initialCount: Int, color: Color) {
            self.label = label
            self.columnIndex = columnIndex
            self.initialCount = initialCount
            self.color = color
        }

        let label: TextLine
        let columnIndex: Int
        let initialCount: Int
        let color: Color

        /// Returns a new instance with an updated `count` value.
        func withInitialCount(_ newValue: Int) -> MoleculeDefinition {
            MoleculeDefinition(
                label: label,
                columnIndex: columnIndex,
                initialCount: newValue,
                color: color
            )
        }
    }

    public struct Timing {

        /// Returns a new instance with default values set for each property.
        public init(
            fadeDuration: TimeInterval = 0.5,
            dropSpeed: Double = 10
        ) {
            self.fadeDuration = fadeDuration
            self.dropSpeed = dropSpeed
        }

        /// The duration of fade in or out animations
        ///
        /// When adding a molecule, it immediately drops down once the fade is is complete.
        let fadeDuration: TimeInterval

        /// Speed of molecules dropping, in rows moved per second
        let dropSpeed: Double
    }

    public struct Settings {
        public init(
            maxMolecules: Int
        ) {
            self.maxMolecules = maxMolecules
        }

        public let maxMolecules: Int
        var maxRowIndex: Int {
            maxMolecules - 1
        }

        /// Returns the time to move from the start row to the end row, with the given
        /// move speed, in terms of rows per time unit
        func moveDuration(
            from startRowIndex: Int,
            to endRowIndex: Int,
            moveSpeed: Double
        ) -> Double {
            moveDuration(
                from: Double(startRowIndex),
                to: Double(endRowIndex),
                moveSpeed: moveSpeed
            )
        }

        // Returns the time to move from the start row to the end row, with the given
        /// move speed, in terms of rows per time unit
        func moveDuration(
            from startRowIndex: Double,
            to endRowIndex: Double,
            moveSpeed: Double
        ) -> Double {
            let dRow = abs(endRowIndex - startRowIndex)
            return moveSpeed == 0 ? 0 : dRow / moveSpeed
        }
    }

    private enum ReactionAction {
        case prepareMoleculeForDropping(type: MoleculeType, id: UUID)
        case moveMoleculeToTopOfColumn(id: UUID)
        case fadeOutBottomMolecules(types: [MoleculeType])
        case deleteBottomMolecules(types: [MoleculeType])
        case slideColumnsDown(types: [MoleculeType])
        case addMolecule(types: [MoleculeType])
        case wait(delay: TimeInterval)
    }

    private struct ActionSequence {
        let id = UUID()
        let added: [MoleculeType]
        let consumed: [MoleculeType]
        var pendingActions: [ReactionAction]

        static func reaction(
            added: MoleculeType,
            consumed: MoleculeType,
            produced: MoleculeType
        ) -> ActionSequence {
            let newMoleculeId = UUID()
            return ActionSequence(
                added: [added, produced],
                consumed: [consumed],
                pendingActions: [
                    .prepareMoleculeForDropping(type: added, id: newMoleculeId),
                    .moveMoleculeToTopOfColumn(id: newMoleculeId),
                    .fadeOutBottomMolecules(types: [added, consumed]),
                    .deleteBottomMolecules(types: [added, consumed]),
                    .slideColumnsDown(types: [added, consumed]),
                    .addMolecule(types: [produced])
                ]
            )
        }

        static func reaction(
            added: MoleculeType,
            consumed: MoleculeType
        ) -> ActionSequence {
            let newMoleculeId = UUID()
            return ActionSequence(
                added: [added],
                consumed: [consumed],
                pendingActions: [
                    .prepareMoleculeForDropping(type: added, id: newMoleculeId),
                    .moveMoleculeToTopOfColumn(id: newMoleculeId),
                    .fadeOutBottomMolecules(types: [added, consumed]),
                    .deleteBottomMolecules(types: [added, consumed]),
                    .slideColumnsDown(types: [added, consumed])
                ]
            )
        }

        static func addMolecules(
            added: MoleculeType,
            delay: TimeInterval? = nil
        ) -> ActionSequence {
            let newMoleculeId = UUID()
            let waitOpt = delay.map { ReactionAction.wait(delay: $0) }
            let wait = [waitOpt].compactMap(identity)
            return ActionSequence(
                added: [added],
                consumed: [],
                pendingActions: wait + [
                    .prepareMoleculeForDropping(type: added, id: newMoleculeId),
                    .moveMoleculeToTopOfColumn(id: newMoleculeId)
                ]
            )
        }

        static func reactionFromExisting(
            consumed: MoleculeType,
            produced: [MoleculeType]
        ) -> ActionSequence {
            return ActionSequence(
                added: produced,
                consumed: [consumed],
                pendingActions: [
                    .fadeOutBottomMolecules(types: [consumed]),
                    .deleteBottomMolecules(types: [consumed]),
                    .slideColumnsDown(types: [consumed]),
                    .addMolecule(types: produced)
                ]
            )
        }

        static func consume(molecule: MoleculeType) -> ActionSequence {
            ActionSequence(
                added: [],
                consumed: [molecule],
                pendingActions: [
                    .fadeOutBottomMolecules(types: [molecule]),
                    .deleteBottomMolecules(types: [molecule]),
                    .slideColumnsDown(types: [molecule])
                ]
            )
        }

        func willRemoveMolecule(ofType moleculeType: MoleculeType) -> Bool {
            pendingActions.contains { action in
                switch action {
                case let .deleteBottomMolecules(types): return types.contains(moleculeType)
                default: return false
                }
            }
        }

        func willAddMolecule(ofType moleculeType: MoleculeType) -> Bool {
            pendingActions.contains { action in
                switch action {
                case let .addMolecule(types): return types.contains(moleculeType)
                case let .prepareMoleculeForDropping(type, id: _): return type == moleculeType
                default: return false
                }
            }
        }
    }
}

