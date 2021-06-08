//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct BufferChartStack: View {

    let layout: BufferScreenLayout
    @ObservedObject var model: BufferScreenViewModel

    var body: some View {
        iceTable
    }

    private var iceTable: some View {
        BufferICEStack(
            phase: model.phase,
            phase1Component: model.weakSubstanceModel,
            phase2Component: model.phase2Model
        )
    }
}

private struct BufferICEStack: View {

    let phase: BufferScreenViewModel.Phase
    @ObservedObject var phase1Component: BufferWeakSubstanceComponents
    @ObservedObject var phase2Component: BufferComponents2

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

struct BufferChartStack_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { geo in
            BufferChartStack(
                layout: BufferScreenLayout(
                    common: AcidBasesScreenLayout(
                        geometry: geo,
                        verticalSizeClass: nil,
                        horizontalSizeClass: nil
                    )
                ),
                model: BufferScreenViewModel()
            )
        }
        .padding()
        .previewLayout(.iPhone8Landscape)
    }
}
