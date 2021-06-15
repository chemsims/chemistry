//
// Reactions App
//

import SwiftUI

struct ReactionProgressChart<MoleculeType : EnumMappable>: View {

    init(model: ReactionProgressChartViewModel<MoleculeType>) {
        self.model = model
        self.geometry = model.geometry
    }

    private typealias Molecule = ReactionProgressChartViewModel<MoleculeType>.Molecule

    @ObservedObject var model: ReactionProgressChartViewModel<MoleculeType>
    let geometry: ReactionProgressChartGeometry

    var body: some View {
        ZStack {
            ForEach(model.molecules) { molecule in
                moleculeView(molecule)
            }
        }
    }

    private func moleculeView(_ molecule: Molecule) -> some View {
        Circle()
            .frame(square: geometry.moleculeSize)
            .scaleEffect(molecule.scale)
            .foregroundColor(molecule.definition.color)
            .position(molecule.position(using: geometry))
            .opacity(molecule.opacity)
    }
}


struct ReactionProgressChart_Previews: PreviewProvider {
    static var previews: some View {
        ViewWrapper(model: ReactionProgressChartViewModel(
            molecules: EnumMap(builder: moleculeDefinition),
            geometry: ReactionProgressChartGeometry(
                chartSize: 300,
                colCount: 3,
                maxMolecules: 10,
                topPadding: 20
            ),
            timing: .init()
        ))
    }

    struct ViewWrapper: View {
        let model: ReactionProgressChartViewModel<TestMoleculeType>

        var body: some View {
            VStack {
                ReactionProgressChart(model: model)
                    .frame(square: 300)
                    .border(Color.red)

                Button(action: {
                    _ = model.addMolecule(.A, reactsWith: .B, producing: .C)
                }) {
                    Text("button")
                }
            }
        }
    }

    private static func moleculeDefinition(_ molecule: TestMoleculeType) -> ReactionProgressChartViewModel<TestMoleculeType>.MoleculeDefinition {
        .init(
            name: molecule.rawValue,
            columnIndex: molecule.data.col,
            initialCount: molecule.data.initCount,
            color: molecule.data.color
        )
    }

    enum TestMoleculeType: String, CaseIterable {
        case A, B, C

        var data: (col: Int, initCount: Int, color: Color) {
            switch self {
            case .A: return (col: 0, initCount: 8, color: .orange)
            case .B: return (col: 1, initCount: 9, color: .purple)
            case .C: return (col: 2, initCount: 5, color: .green)
            }
        }
    }
}
