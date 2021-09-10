//
// Reactions App
//

import XCTest
@testable import ChemicalReactions

class BalancedReactionScreenViewModelTests: XCTestCase {

    func testPreviousMoleculesAreMaintainedWhenGoingBack() {
        let model = BalancedReactionScreenViewModel()
        model.didSelectReaction()
        let nav = model.navigation!
        nav.nextUntil { $0.inputState == .dragMolecules }

        let firstReaction = model.reaction

        let firstReactantType = firstReaction.reactants.first.molecule
        let firstProductType = firstReaction.products.first.molecule

        let firstReactantMolecule = model.moleculePosition.gridMolecule(of: firstReactantType)
        let firstProductMolecule = model.moleculePosition.gridMolecule(of: firstProductType)

        model.drop(molecule: firstReactantMolecule, on: .reactant)
        model.drop(molecule: firstProductMolecule, on: .product)

        // On select reaction state - molecules should remain the same
        nav.next()
        XCTAssertEqual(model.inputState, .selectReaction)
        XCTAssertEqual(model.moleculePosition.reactionBalancer.count(of: firstReactantType), 1)
        XCTAssertEqual(model.moleculePosition.reactionBalancer.count(of: firstProductType), 1)

        let newReaction = BalancedReaction.availableReactions.filter { $0 != model.reaction }.first!
        model.reaction = newReaction
        model.didSelectReaction()

        // After selecting reaction, molecules should be reset
        XCTAssertEqual(model.inputState, .dragMolecules)
        XCTAssertEqual(model.moleculePosition.molecules.count, newReaction.totalElementCount)

        // On going back, should restore the same molecules as before
        nav.back()

        XCTAssertEqual(model.inputState, .selectReaction)
        XCTAssertEqual(model.reaction, firstReaction)
        XCTAssertEqual(model.moleculePosition.molecules.count, firstReaction.totalElementCount + 2)
        XCTAssertEqual(model.moleculePosition.reactionBalancer.totalMolecules, 2)
    }

    func testPreviousMoleculesAreMaintainedWhenGoingBackTwice() {
        let model = BalancedReactionScreenViewModel()
        model.didSelectReaction()
        let nav = model.navigation!
        let firstReaction = BalancedReaction.availableReactions[0]
        model.reaction = firstReaction
        nav.nextUntil { $0.inputState == .selectReaction }

        let secondReaction = BalancedReaction.availableReactions[1]
        model.reaction = secondReaction
        model.didSelectReaction()

        nav.nextUntil { $0.inputState == .selectReaction }

        let thirdReaction = BalancedReaction.availableReactions[2]
        model.reaction = thirdReaction
        model.didSelectReaction()

        nav.back()
        XCTAssertEqual(model.reaction, secondReaction)

        nav.back()
        nav.backUntil { $0.inputState == .selectReaction }
        XCTAssertEqual(model.reaction, firstReaction)
    }

    func testReactionsBecomeUnavailableWhenTheyAreUsed() {
        let model = BalancedReactionScreenViewModel()
        let nav = model.navigation!

        XCTAssertEqual(model.unavailableReactions, [])

        let firstReaction = model.reaction
        model.didSelectReaction()

        var chosenReactions: [BalancedReaction] = [firstReaction]

        func goToNextReactionSelection() {
            nav.nextUntil { $0.inputState == .selectReaction }
        }

        var nextNonSelectedReaction: BalancedReaction? {
            BalancedReaction.availableReactions.filter { !chosenReactions.contains($0) }.first
        }

        while let nextReaction = nextNonSelectedReaction {
            goToNextReactionSelection()
            XCTAssertArraysContainTheSameElements(model.unavailableReactions, chosenReactions)
            model.reaction = nextReaction
            chosenReactions.append(nextReaction)
            model.didSelectReaction()
        }

        nav.backWhile(\.hasSelectedFirstReaction)
        XCTAssertEqual(model.unavailableReactions, [])
    }
}

private extension BalancedReaction {
    var totalElementCount: Int {
        reactants.count.int + products.count.int
    }
}

private extension BalancedReaction.ElementCount {
    var int: Int {
        switch self {
        case .one: return 1
        case .two: return 2
        }
    }
}

private extension BalancedReactionMoleculePositionViewModel {

    func gridMolecule(of type: BalancedReaction.Molecule) -> MovingMolecule {
        molecules.first { molecule in
            !molecule.isInBeaker && molecule.moleculeType == type
        }!
    }
}

private extension ReactionBalancer {
    var totalMolecules: Int {
        totalCount(of: reaction.reactants) + totalCount(of: reaction.products)
    }

    private func totalCount(of elements: BalancedReaction.Elements) -> Int {
        elements.asArray.map { element in
            count(of: element.molecule)
        }.sum()
    }
}
