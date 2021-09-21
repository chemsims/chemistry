//
// Reactions App
//

import XCTest
import SwiftUI
@testable import ReactionsCore

private typealias MoleculeDefinition = ReactionProgressChartViewModel<TestMolecule>.MoleculeDefinition
private typealias Data = ReactionProgressChartViewModel<TestMolecule>.Molecule

class ReactionProgressChartViewModelTests: XCTestCase {

    func testInitialisingModelData() {
        let model = newModel(timing: .init(fadeDuration: 0.2))

        let aData = model.sortedData(.A)
        let bData = model.sortedData(.B)
        let cData = model.sortedData(.C)

        XCTAssertEqual(aData.count, 5)
        XCTAssertEqual(bData.count, 4)
        XCTAssertEqual(cData.count, 0)

        func checkPosition(_ data: [Data], colIndex: Int) {
            data.indices.forEach { row in
                XCTAssertEqual(data[row].rowIndex, row)
                XCTAssertEqual(data[row].definition.columnIndex, colIndex)
            }
        }

        checkPosition(aData, colIndex: 0)
        checkPosition(bData, colIndex: 1)
        checkPosition(cData, colIndex: 2)
    }

    func testAddingAMoleculeMovesItToTheTopOfTheColumn() {
        let model = newModel(timing: .init(fadeDuration: 0.2))
        let delegate = TestReactionProgressChartViewModelDelegate()
        model.delegate = delegate
        let wasAdded = model.startReaction(adding: .A, reactsWith: .B, producing: .C)
        XCTAssert(wasAdded)

        XCTAssertEqual(model.sortedData(.A).count, 6)
        XCTAssertEqual(model.sortedData(.A).last!.rowIndex, 9)
        let newId = model.sortedData(.A).last!.id

        let moveToTopOfColumnExpectation = delegate.addWillMoveMoleculeToTopOfColumnExpectation(forId: newId)

        wait(for: [moveToTopOfColumnExpectation], timeout: 1)

        XCTAssertEqual(model.sortedData(.A).last?.rowIndex, 5)
    }

    func testAddingTwoMoleculesMoveThemBothToTheTopOfTheColumn() {
        let model = newModel(timing: .init(fadeDuration: 0.2))
        let delegate = TestReactionProgressChartViewModelDelegate()
        model.delegate = delegate

        func doAdd() -> XCTestExpectation {
            let wasAdded = model.startReaction(adding: .A, reactsWith: .B, producing: .C)
            XCTAssert(wasAdded)
            let newId = model.sortedData(.A).last!.id
            return delegate.addWillMoveMoleculeToTopOfColumnExpectation(forId: newId)
        }

        let firstMoleculeExpectation = doAdd()
        let secondMoleculeExpectation = doAdd()

        wait(for: [firstMoleculeExpectation, secondMoleculeExpectation], timeout: 0.5)

        XCTAssertEqual(model.sortedData(.A)[5].rowIndex, 5)
        XCTAssertEqual(model.sortedData(.A)[6].rowIndex, 6)
    }

    func testAddingMoleculesToAnEmptyColumnMovesItToBottomOfChart() {
        let model = newModel(timing: .init(fadeDuration: 0.2))
        let delegate = TestReactionProgressChartViewModelDelegate()
        model.delegate = delegate

        let wasAdded = model.startReaction(adding: .C, reactsWith: .B, producing: .A)
        XCTAssert(wasAdded)
        let newId = model.sortedData(.C).last!.id
        let expectation = delegate.addWillMoveMoleculeToTopOfColumnExpectation(forId: newId)

        wait(for: [expectation], timeout: 0.5)

        XCTAssertEqual(model.sortedData(.C).last!.rowIndex, 0)
    }

    func testMoleculesFadeOutAfterAddingOne() {
        let model = newModel(timing: .init(fadeDuration: 0.1, dropSpeed: 10))
        let delegate = TestReactionProgressChartViewModelDelegate()
        model.delegate = delegate

        let wasAdded = model.startReaction(adding: .A, reactsWith: .B, producing: .C)
        XCTAssert(wasAdded)
        let expectation = delegate.addWillFadeoutBottomMoleculesExpectation(molecules: [.A, .B])

        wait(for: [expectation], timeout: 2)

        func checkFirstMolecule(_ molecule: TestMolecule) {
            let firstMolecule = model.getMolecules(ofType: molecule).first!
            XCTAssertEqual(firstMolecule.rowIndex, 0)
            XCTAssertEqual(firstMolecule.opacity, 0)
        }

        checkFirstMolecule(.A)
        checkFirstMolecule(.B)
    }

    func testMoleculeColumnsMoveDownAfterAddingOne() {
        let model = newModel(timing: .init(fadeDuration: 0.1, dropSpeed: 10))
        let delegate = TestReactionProgressChartViewModelDelegate()
        model.delegate = delegate

        let wasAdded = model.startReaction(adding: .A, reactsWith: .B, producing: .C)
        XCTAssert(wasAdded)
        let expectation = delegate.addWillSlideColumnsDownExpectation(molecules: [.A, .B])

        wait(for: [expectation], timeout: 1)


        func checkRowIndices(_ molecule: TestMolecule, count: Int) {
            let rows = model.sortedData(molecule).map(\.rowIndex)
            XCTAssertEqual(rows, Array(0..<count))
        }

        checkRowIndices(.A, count: TestMolecule.A.defaultInitCount)
        checkRowIndices(.B, count: TestMolecule.B.defaultInitCount - 1)
    }

    func testMoleculeColumnsMoveDownTwiceAfterAddingTwoMolecules() {
        let model = newModel(timing: .init(fadeDuration: 0.1, dropSpeed: 10))
        let delegate = TestReactionProgressChartViewModelDelegate()
        model.delegate = delegate

        _ = model.startReaction(adding: .A, reactsWith: .B, producing: .C)
        _ = model.startReaction(adding: .A, reactsWith: .B, producing: .C)

        let firstExpectation = delegate.addWillSlideColumnsDownExpectation(molecules: [.A, .B])
        let secondExpectation = delegate.addWillSlideColumnsDownExpectation(molecules: [.A, .B])
        wait(for: [firstExpectation, secondExpectation], timeout: 1)

        func checkRowIndices(_ molecule: TestMolecule, count: Int) {
            let rows = model.sortedData(molecule).map(\.rowIndex)
            XCTAssertEqual(rows, Array(0..<count))
        }

        checkRowIndices(.A, count: TestMolecule.A.defaultInitCount)
        checkRowIndices(.B, count: TestMolecule.B.defaultInitCount - 2)
    }

    func testProducedMoleculeIsAddedAfterAddingADifferentMolecule() {
        let model = newModel(timing: .init(fadeDuration: 0.1, dropSpeed: 50))
        let delegate = TestReactionProgressChartViewModelDelegate()
        model.delegate = delegate

        let wasAdded = model.startReaction(adding: .A, reactsWith: .B, producing: .C)
        XCTAssert(wasAdded)
        let expectation = delegate.addWillAddMoleculeToTopOfColumnExpectation(ofTypes: [.C])

        wait(for: [expectation], timeout: 1)

        let cMolecules = model.sortedData(.C)
        XCTAssertEqual(cMolecules.count, 1)
        XCTAssertEqual(cMolecules.first!.opacity, 1)
        XCTAssertEqual(cMolecules.first!.scale, 1)
    }

    func testThatMoleculeIsNotAddedWhenThereIsNoConsumableMoleculeLeft() {
        let model = newModel()
        let wasAdded = model.startReaction(adding: .A, reactsWith: .C, producing: .B)
        XCTAssertFalse(wasAdded)
    }

    func testThatMoleculeIsNotAddedWhenThereWontBeAnyConsumableMoleculesLeftAfterPreviousAction() {
        let counts = EnumMap<TestMolecule, Int> {
            switch $0 {
            case .A: return 5
            case .B: return 5
            case .C: return 1
            }
        }
        let model = newModel(
            timing: .init(fadeDuration: 0.1, dropSpeed: 500),
            definitions: TestMolecule.definitions(withCounts: counts)
        )
        let delegate = TestReactionProgressChartViewModelDelegate()
        model.delegate = delegate

        // We have a C molecule, so we can safely start the A + C -> B reaction
        let consumeNonEmptyC1 = model.startReaction(adding: .A, reactsWith: .C, producing: .B)
        XCTAssert(consumeNonEmptyC1)

        // Since the only C molecule will be consumed by the above reaction, we
        // expect trying to consume another C will fail
        let consumeEmptyC = model.startReaction(adding: .A, reactsWith: .C, producing: .B)
        XCTAssertFalse(consumeEmptyC)

        // Now, we want to wait for C to be consumed before continuing
        let consumedCExpectation = delegate.addWillFadeoutBottomMoleculesExpectation(molecules: [.A, .C])
        wait(for: [consumedCExpectation], timeout: 1)

        // We now produce a C molecule
        let produceC = model.startReaction(adding: .A, reactsWith: .B, producing: .C)
        XCTAssert(produceC)

        // wait until the new C molecule has been added
        let producedCExpectation = delegate.addWillAddMoleculeToTopOfColumnExpectation(ofTypes: [.C])
        wait(for: [producedCExpectation], timeout: 1)

        XCTAssertEqual(model.sortedData(.C).count, 1)

        // Since we have 1 C molecule again, we should be able to run another reaction
        // which consumes C
        let consumeNonEmptyC2 = model.startReaction(adding: .A, reactsWith: .C, producing: .B)
        XCTAssert(consumeNonEmptyC2)
    }

    func testThatMoleculeIsNotAddedWhenThereIsNoSpaceLeftInColumnOfMoleculeBeingAdded() {
        let counts = EnumMap<TestMolecule, Int> {
            switch $0 {
            case .A: return 10
            case .B: return 5
            case .C: return 1
            }
        }
        let model = newModel(definitions: TestMolecule.definitions(withCounts: counts))

        let didAdd = model.startReaction(adding: .A, reactsWith: .B, producing: .C)
        XCTAssertFalse(didAdd)
    }

    func testThatMoleculeIsNotAddedWhenThereIsNoSpaceLeftInColumnOfMoleculeBeingProduced() {
        let counts = EnumMap<TestMolecule, Int> {
            switch $0 {
            case .A: return 10
            case .B: return 5
            case .C: return 1
            }
        }
        let model = newModel(definitions: TestMolecule.definitions(withCounts: counts))

        let didAdd = model.startReaction(adding: .B, reactsWith: .C, producing: .A)
        XCTAssertFalse(didAdd)
    }

    func testThatMoleculeIsNotAddedWhenThereWillBeNoSpaceLeftInColumnOfMoleculeBeingProducedAfterPreviousReactionCompletes() {
        let counts = EnumMap<TestMolecule, Int> {
            switch $0 {
            case .A: return 9
            case .B: return 5
            case .C: return 5
            }
        }
        let model = newModel(definitions: TestMolecule.definitions(withCounts: counts))

        let firstAdd = model.startReaction(adding: .B, reactsWith: .C, producing: .A)
        XCTAssert(firstAdd)

        let secondAdd = model.startReaction(adding: .B, reactsWith: .C, producing: .A)
        XCTAssertFalse(secondAdd)
    }

    func testConsumingMultipleMolecules() {
        let counts = EnumMap<TestMolecule, Int> { _ in 3 }

        let model = newModel(
            timing: .init(fadeDuration: 0.1, dropSpeed: 50),
            definitions: TestMolecule.definitions(withCounts: counts)
        )
        let delegate = TestReactionProgressChartViewModelDelegate()
        model.delegate = delegate

        let expectFadeOut = delegate.addWillFadeoutBottomMoleculesExpectation(
            molecules: [.A]
        )
        let expectRemoval = delegate.addWillRemoveBottomMoleculesExpectation(
            molecules: [.A]
        )
        let expectSlideDown = delegate.addWillSlideColumnsDownExpectation(
            molecules: [.A]
        )

        let firstConsume = model.consume(.A, count: 2)
        XCTAssert(firstConsume)
        XCTAssertEqual(model.moleculeCounts(ofType: .A), 1)

        wait(for: [expectFadeOut], timeout: 1)

        let fadedOutMolecules = model.getMolecules(ofType: .A).filter {
            $0.opacity == 0
        }.count
        XCTAssertEqual(fadedOutMolecules, 2)

        wait(for: [expectRemoval], timeout: 1)
        XCTAssertEqual(model.getMolecules(ofType: .A).count, 1)

        wait(for: [expectSlideDown], timeout: 1)
        XCTAssertEqual(model.getMolecules(ofType: .A).first!.rowIndex, 0)

        let secondConsume = model.consume(.A, count: 2)
        XCTAssertFalse(secondConsume)
    }

    func testConsumingMultipleMoleculesWhileOneIsInProgress() {
        let counts = EnumMap<TestMolecule, Int> { _ in 5 }

        let model = newModel(
            timing: .init(fadeDuration: 0.1, dropSpeed: 50),
            definitions: TestMolecule.definitions(withCounts: counts)
        )
        let delegate = TestReactionProgressChartViewModelDelegate()
        model.delegate = delegate

        // note - it's important to use a molecule other than A here, there
        // was a bug which wasn't revealed when testing with the first column
        let firstFadeOut = delegate.addWillFadeoutBottomMoleculesExpectation(molecules: [.B])
        let secondFadeOut = delegate.addWillFadeoutBottomMoleculesExpectation(molecules: [.B])

        let firstRemoval = delegate.addWillRemoveBottomMoleculesExpectation(molecules: [.B])
        let secondRemoval = delegate.addWillRemoveBottomMoleculesExpectation(molecules: [.B])

        let firstConsume = model.consume(.B, count: 2)
        let secondConsume = model.consume(.B, count: 2)

        XCTAssert(firstConsume)
        XCTAssert(secondConsume)

        XCTAssertEqual(model.moleculeCounts(ofType: .B), 1)

        wait(for: [firstFadeOut], timeout: 1)
        wait(for: [secondFadeOut], timeout: 1)

        let fadedOutMolecules = model.getMolecules(ofType: .B).filter {
            $0.opacity == 0
        }.count
        XCTAssertEqual(fadedOutMolecules, 4)

        wait(for: [firstRemoval], timeout: 1)
        wait(for: [secondRemoval], timeout: 1)

        XCTAssertEqual(model.getMolecules(ofType: .B).count, 1)
    }
    
    private func newModel(
        timing: ReactionProgressChartViewModel<TestMolecule>.Timing = .init(),
        definitions: EnumMap<TestMolecule, MoleculeDefinition> = TestMolecule.defaultDefinitions
    ) -> ReactionProgressChartViewModel<TestMolecule> {
        ReactionProgressChartViewModel(
            molecules: definitions,
            settings: .init(maxMolecules: 10),
            timing: timing
        )
    }
}



private enum TestMolecule: String, CaseIterable {
    case A, B, C

    var defaultInitCount: Int {
        switch self {
        case .A: return 5
        case .B: return 4
        case .C: return 0
        }
    }

    var colIndex: Int {
        switch self {
        case .A: return 0
        case .B: return 1
        case .C: return 2
        }
    }

    static var defaultDefinitions: EnumMap<TestMolecule, MoleculeDefinition> {
        definitions(withCounts: .init(builder: { $0.defaultInitCount }  ))
    }

    static func definitions(withCounts initialCounts: EnumMap<TestMolecule, Int>) -> EnumMap<TestMolecule, MoleculeDefinition> {
        .init(builder: { molecule in
            definition(molecule: molecule, count: initialCounts.value(for: molecule))
        })
    }

    private static func definition(
        molecule: TestMolecule,
        count: Int
    )  -> MoleculeDefinition {
        MoleculeDefinition(
            label: "\(molecule.rawValue)",
            columnIndex: molecule.colIndex,
            initialCount: count,
            color: .purple
        )
    }
}

private class TestReactionProgressChartViewModelDelegate: ReactionProgressChartViewModelDelegate<TestMolecule> {

    func addWillMoveMoleculeToTopOfColumnExpectation(forId id: UUID) -> XCTestExpectation {
        let expectation = XCTestExpectation(description: "Will move molecule \(id) to top of column")
        moveToTopOfColumnExpectations[id] = expectation
        return expectation
    }

    func addWillFadeoutBottomMoleculesExpectation(
        molecules: [TestMolecule]
    ) -> XCTestExpectation {
        fadeOuts.addExpectation(molecules: molecules)
    }

    func addWillSlideColumnsDownExpectation(molecules: [TestMolecule]) -> XCTestExpectation {
        slideDowns.addExpectation(molecules: molecules)
    }

    func addWillAddMoleculeToTopOfColumnExpectation(ofTypes types: [TestMolecule]) -> XCTestExpectation {
        addMolecules.addExpectation(molecules: types)
    }

    func addWillRemoveBottomMoleculesExpectation(molecules: [TestMolecule]) -> XCTestExpectation {
        removeMolecules.addExpectation(molecules: molecules)
    }

    private var moveToTopOfColumnExpectations = [UUID : XCTestExpectation]()
    private let fadeOuts = ExpectationHolder(description: "fade out")
    private let slideDowns = ExpectationHolder(description: "slide down")
    private let addMolecules = ExpectationHolder(description: "add molecules")
    private let removeMolecules = ExpectationHolder(description: "remove molecules")


    override func willMoveMoleculeToTopOfColumn(withId id: UUID) {
        if let expectation = moveToTopOfColumnExpectations[id] {
            expectation.fulfill()
        }
    }

    override func willFadeOutBottomMolecules(ofTypes types: [TestMolecule]) {
        fadeOuts.fulfil(molecules: types)
    }

    override func willSlideColumnsDown(ofTypes types: [TestMolecule]) {
        slideDowns.fulfil(molecules: types)
    }

    override func willAddMoleculeToTopOfColumn(ofTypes types: [TestMolecule]) {
        addMolecules.fulfil(molecules: types)
    }

    override func willRemoveBottomMolecules(ofTypes types: [TestMolecule]) {
        removeMolecules.fulfil(molecules: types)
    }
}


private class ExpectationHolder {

    init(description: String) {
        self.description = description
    }

    let description: String

    private var expectations = [[TestMolecule] : [XCTestExpectation]]()
    private var remainingCounts = [[TestMolecule] : Int]()

    func addExpectation(molecules: [TestMolecule]) -> XCTestExpectation {
        let expectation = XCTestExpectation(description: "\(description): \(molecules)")
        let existing = expectations[molecules] ?? []
        expectations[molecules] = existing + [expectation]
        return expectation
    }

    func fulfil(molecules: [TestMolecule]) {
        if let expectations = expectations[molecules], let first = expectations.first {
            first.fulfill()
            self.expectations[molecules] = Array(expectations.dropFirst())
        }
    }
}

private extension ReactionProgressChartViewModel {
    func sortedData(_ molecule: MoleculeType) -> [Molecule] {
        getMolecules(ofType: molecule).sorted(
            by: { $0.rowIndex < $1.rowIndex }
        )
    }
}
