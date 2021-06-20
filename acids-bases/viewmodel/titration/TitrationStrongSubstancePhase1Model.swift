//
// Reactions App
//

import SwiftUI
import ReactionsCore

class TitrationStrongSubstancePhase1Model: ObservableObject {

    init(
        cols: Int,
        rows: CGFloat,
        settings: TitrationSettings
    ) {
        self.settings = settings
        self.cols = cols
        self.rows = rows
        self.primaryIonCoords = BeakerMolecules(
            coords: [],
            color: .purple,
            label: "" // TODO label
        )
    }

    let settings: TitrationSettings
    let cols: Int
    var rows: CGFloat

    var gridRows: Int {
        GridCoordinateList.availableRows(for: rows)
    }

    @Published var primaryIonCoords: BeakerMolecules
    @Published var substanceAdded: Int = 0

    var gridCount: Int {
        gridRows * cols
    }
}

// MARK: Incrementing
extension TitrationStrongSubstancePhase1Model {
    func incrementSubstance(count: Int) {
        guard count > 0 else {
            return
        }

        primaryIonCoords.coords = GridCoordinateList.addingRandomElementsTo(
            grid: primaryIonCoords.coords,
            count: count,
            cols: cols,
            rows: gridRows
        )
        withAnimation(.linear(duration: 1)) {
            substanceAdded += count
        }
    }
}

// MARK: Bar chart data
extension TitrationStrongSubstancePhase1Model {
    var barChartData: [BarChartData] {
        [
            BarChartData(
                label: "",
                equation: LinearEquation(
                    x1: 0,
                    y1: 0,
                    x2: CGFloat(maxSubstance),
                    y2: CGFloat(maxSubstance) / CGFloat(gridCount)
                ),
                color: .purple,
                accessibilityLabel: ""
            ),
            BarChartData(
                label: "",
                equation: ConstantEquation(value: 0),
                color: .purple,
                accessibilityLabel: ""
            )
        ]
    }
}

// MARK: Input limits
extension TitrationStrongSubstancePhase1Model {
    var maxSubstance: Int {
        20
    }
}
