//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct TitrationBarsOrReactionProgress: View {

    let layout: TitrationScreenLayout
    @ObservedObject var model: TitrationViewModel
    @ObservedObject var phase1Model: TitrationStrongSubstancePhase1Model

    var body: some View {
        BarChart(
            data: phase1Model.barChartData,
            time: CGFloat(phase1Model.substanceAdded),
            settings: layout.common.barChartSettings
        )
    }
}
