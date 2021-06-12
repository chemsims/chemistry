//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct BufferPHChartOrTable: View {

    let layout: BufferScreenLayout
    @ObservedObject var model: BufferScreenViewModel

    @State private var showingTable = false

    var body: some View {
        VStack(spacing: 0) {
            toggle
            if showingTable {
                table
            } else {
                graph
            }
        }
    }

    private var toggle: some View {
        HStack {
            SelectionToggleText(
                text: "Graph",
                isSelected: !showingTable,
                action: { showingTable = false }
            )
            SelectionToggleText(
                text: "Table",
                isSelected: showingTable,
                action: { showingTable = true }
            )
        }
        .font(.system(size: layout.common.toggleFontSize))
        .frame(height: layout.common.toggleHeight)
        .minimumScaleFactor(0.5)
    }

    private var graph: some View {
        BufferPhChart(
            layout: layout,
            model: model,
            strongModel: model.strongSubstanceModel
        )
    }

    private var table: some View {
        BufferICETable(
            phase: model.phase,
            phase1Component: model.weakSubstanceModel,
            phase2Component: model.saltComponents
        )
        .frame(size: layout.tableSize)
    }
}

private struct BufferICETable: View {

    let phase: BufferScreenViewModel.Phase
    @ObservedObject var phase1Component: BufferWeakSubstanceComponents
    @ObservedObject var phase2Component: BufferSaltComponents

    var body: some View {
        Group {
            if phase == .addWeakSubstance {
                ICETable(
                    columns: phase1Component.tableData,
                    x: phase1Component.progress
                )
            } else {
                ICETable(
                    columns: phase2Component.tableData,
                    x: CGFloat(phase2Component.substanceAdded)
                )
            }
        }
    }
}
