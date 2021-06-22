//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct TitrationBarsOrReactionProgress: View {

    let layout: TitrationScreenLayout
    @ObservedObject var strongSubstancePreparationModel: TitrationStrongSubstancePreparationModel

    var body: some View {
        BarChart(
            data: strongSubstancePreparationModel.barChartData,
            time: CGFloat(strongSubstancePreparationModel.substanceAdded),
            settings: layout.common.barChartSettings
        )
    }
}
