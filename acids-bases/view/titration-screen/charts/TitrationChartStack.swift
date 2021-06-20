//
// Reactions App
//


import SwiftUI

struct TitrationChartStack: View {

    let layout: TitrationScreenLayout
    @ObservedObject var model: TitrationViewModel

    var body: some View {
        VStack(spacing: 0) {
            TitrationPhChart(layout: layout)
            Spacer(minLength: 0)
            TitrationBarsOrReactionProgress(
                layout: layout,
                model: model,
                phase1Model: model.strongSubstancePhase1Model
            )
        }
    }
}

