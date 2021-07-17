//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct BufferPHChartOrTable: View {

    let layout: BufferScreenLayout
    @ObservedObject var model: BufferScreenViewModel

    var body: some View {
        VStack(spacing: 0) {
            toggle
            if model.selectedTopView == .table {
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
                isSelected: model.selectedTopView == .chart,
                action: { model.selectedTopView = .chart }
            )
            SelectionToggleText(
                text: "Table",
                isSelected: model.selectedTopView == .table,
                action: { model.selectedTopView = .table }
            )
        }
        .font(.system(size: layout.common.toggleFontSize))
        .frame(height: layout.common.toggleHeight)
        .minimumScaleFactor(0.5)
        .colorMultiply(model.highlights.colorMultiply(for: nil))
    }

    private var graph: some View {
        BufferPhChart(
            layout: layout,
            model: model,
            strongModel: model.strongSubstanceModel
        )
        .background(
            Color.white
                .padding(.trailing, -0.05 * layout.common.chartSize)
        )
        .colorMultiply(model.highlights.colorMultiply(for: .topChart))
    }

    private var table: some View {
        BufferICETable(
            phase: model.phase,
            weakModel: model.weakSubstanceModel,
            saltModel: model.saltModel,
            strongModel: model.strongSubstanceModel
        )
        .frame(size: layout.tableSize)
        .colorMultiply(model.highlights.colorMultiply(for: nil))
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
