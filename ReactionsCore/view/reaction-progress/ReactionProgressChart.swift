//
// Reactions App
//

import SwiftUI

public struct ReactionProgressChart<MoleculeType : EnumMappable>: View {

    private typealias MoleculeDefinition = ReactionProgressChartViewModel<MoleculeType>.MoleculeDefinition

    public init(
        model: ReactionProgressChartViewModel<MoleculeType>,
        geometry: ReactionProgressChartGeometry<MoleculeType>
    ) {
        self.model = model
        self.geometry = geometry
    }

    private typealias Molecule = ReactionProgressChartViewModel<MoleculeType>.Molecule

    @ObservedObject var model: ReactionProgressChartViewModel<MoleculeType>
    let geometry: ReactionProgressChartGeometry<MoleculeType>

    public var body: some View {
        VStack(spacing: geometry.chartToAxisSpacing) {
            plotArea
            axis
        }
    }
}

// MARK: Molecules
extension ReactionProgressChart {
    var plotArea: some View {
        ZStack {
            Path { p in
                p.addLines([
                    .zero,
                    CGPoint(x: 0, y: geometry.chartSize),
                    CGPoint(x: geometry.chartSize, y: geometry.chartSize),
                    CGPoint(x: geometry.chartSize, y: 0)
                ])
            }
            .stroke()

            ForEach(model.molecules) { molecule in
                moleculeView(molecule)
            }
        }
        .frame(square: geometry.chartSize)
    }

    // NB: Using a scale of 0 results in warnings being printed
    // in the console, so make sure the scale is above 0
    private func moleculeView(_ molecule: Molecule) -> some View {
        Circle()
            .frame(square: geometry.moleculeSize)
            .scaleEffect(max(0.001, molecule.scale))
            .foregroundColor(molecule.definition.color)
            .position(molecule.position(using: geometry))
            .opacity(molecule.opacity)
            .transition(.identity)
    }
}

// MARK: Label
extension ReactionProgressChart {
    private var axis: some View {
        CircleChartLabel(
            layout: geometry.axisLayout,
            labels: model
                .definitions
                .all
                .sorted(by: { $0.columnIndex < $1.columnIndex})
                .enumerated().map { (i, data) in
                .init(
                    id: i,
                    label: data.label,
                    color: data.color
                )
            }
        )
        .frame(width: geometry.chartSize)
    }
}

struct ReactionProgressChart_Previews: PreviewProvider {
    static var previews: some View {
        ViewWrapper(model: ReactionProgressChartViewModel(
            molecules: EnumMap(builder: moleculeDefinition),
            settings: .init(maxMolecules: 10),
            timing: .init(dropSpeed: 11)
        ))
    }

    struct ViewWrapper: View {
        let model: ReactionProgressChartViewModel<TestMoleculeType>

        var body: some View {
            VStack {
                ReactionProgressChart(
                    model: model,
                    geometry: ReactionProgressChartGeometry(
                        chartSize: 200,
                        moleculeType: TestMoleculeType.self,
                        maxMolecules: 10,
                        topPadding: 0
                    )
                )

                Button(action: {
//                    _ = model.startReaction(adding: .A, reactsWith: .B, producing: .C)
                    _ = model.startReactionFromExisting(consuming: .A, producing: [.B, .C])
                }) {
                    Text("Start reaction")
                }

                HStack {
                    ForEach(TestMoleculeType.allCases) { molecule in
                        Button(action: {
                            _ = model.addMolecule(molecule)
                        }) {
                            Text("Add \(molecule.rawValue)")
                        }
                    }
                }
            }
        }
    }

    private static func moleculeDefinition(_ molecule: TestMoleculeType) -> ReactionProgressChartViewModel<TestMoleculeType>.MoleculeDefinition {
        .init(
            label: "\(molecule.rawValue)",
            columnIndex: molecule.data.col,
            initialCount: molecule.data.initCount,
            color: molecule.data.color
        )
    }

    enum TestMoleculeType: String, CaseIterable, Identifiable {
        case A, B, C, D, E

        var id: String {
            rawValue
        }

        var data: (col: Int, initCount: Int, color: Color) {
            switch self {
            case .A: return (col: 0, initCount: 3, color: .orange)
            case .B: return (col: 1, initCount: 9, color: .purple)
            case .C: return (col: 2, initCount: 5, color: .green)
            case .D: return (col: 3, initCount: 0, color: .blue)
            case .E: return (col: 3, initCount: 5, color: .black)
            }
        }
    }
}

