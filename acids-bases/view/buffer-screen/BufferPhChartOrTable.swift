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
            weakModel: model.weakSubstanceModel,
            saltModel: model.saltComponents,
            strongModel: model.strongSubstanceModel
        )
        .frame(size: layout.tableSize)
    }
}

private struct BufferICETable: View {

    let phase: BufferScreenViewModel.Phase
    @ObservedObject var weakModel: BufferWeakSubstanceComponents
    @ObservedObject var saltModel: BufferSaltComponents
    @ObservedObject var strongModel: BufferStrongSubstanceComponents

    var body: some View {
        ICETable(columns: columns, x: progress)
    }

    private var columns: [ICETableColumn] {
        switch phase {
        case .addWeakSubstance: return weakModel.tableData
        case .addSalt: return saltModel.tableData
        case .addStrongSubstance: return strongModel.tableData
        }
    }

    private var progress: CGFloat {
        switch phase {
        case .addWeakSubstance: return weakModel.progress
        case .addSalt: return CGFloat(saltModel.substanceAdded)
        case .addStrongSubstance: return CGFloat(strongModel.substanceAdded)
        }
    }
}
