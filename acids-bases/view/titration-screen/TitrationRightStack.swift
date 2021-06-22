//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct TitrationRightStack: View {

    let layout: TitrationScreenLayout
    @ObservedObject var model: TitrationViewModel
    @ObservedObject var strongSubstancePreparationModel: TitrationStrongSubstancePreparationModel

    var body: some View {
        VStack(spacing: 0) {
            TitrationEquationView(
                data: strongSubstancePreparationModel.equationData,
                equationSet: model.equationState.equationSet
            )
            Spacer(minLength: 0)
            BeakyBox(
                statement: model.statement,
                next: model.next,
                back: model.back,
                nextIsDisabled: model.nextIsDisabled,
                settings: layout.common.beakySettings
            )
        }
    }
}
